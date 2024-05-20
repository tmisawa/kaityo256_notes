$L = 16
$Q = 4
$N = $L**2
$spin = Array.new($N){rand()*Math::PI*2}
$bond_x = Array.new($N){false}
$bond_y = Array.new($N){false}
$cindex = Array.new($N)

def s2rgb(s)
  h = (s/Math::PI/2.0*360).to_i % 360
  x = (1 - ((h / 60.0) % 2 - 1).abs)
  c = 1
  r, g, b = case
            when h < 60  then [c, x, 0]
            when h < 120 then [x, c, 0]
            when h < 180 then [0, c, x]
            when h < 240 then [0, x, c]
            when h < 300 then [x, 0, c]
            else              [c, 0, x]
            end  
  return r,g,b
end

def get_cluster_index(i)
  while i != $cindex[i]
    i = $cindex[i]
  end
  i
end

def connect(i1,i2,beta,r)
  s1 = $spin[i1]
  s2 = $spin[i2]
  dE = Math::cos(s1-s2) - Math::cos(s1+s2 - 2.0 *r)
  return false if rand() > 1.0 - Math::exp(-beta*dE)  
  c1 = get_cluster_index(i1)
  c2 = get_cluster_index(i2)
  if c1 < c2
    $cindex[c2] = c1
  else
    $cindex[c1] = c2
  end
  true 
end

def p2i(ix,iy)
  ix = ix % $L
  iy = iy % $L
  return (ix + iy * $L)
end

def clustering(beta,r)
  $N.times{|i|
    $cindex[i] = i
    $bond_x[i] = false
    $bond_y[i] = false
  }
  $N.times{|i|
    ix = i % $L
    iy = (i/$L).to_i
    $bond_x[i] = connect(i,p2i(ix+1,iy),beta,r)
    $bond_y[i] = connect(i,p2i(ix,iy+1),beta,r)
  }
end

def sw_flip(beta)
  flip = Array.new($N){(rand() > 0.5)}
  r = rand()*Math::PI*2
  clustering(beta,0.0)
end

def single_flip(beta)
  $N.times{|i|
    ns = (rand()*$Q).to_i
    ix = i % $L
    iy = (i / $L).to_i
    old_sum = 0
    old_sum = old_sum + 1 if $spin[i] == $spin[p2i(ix+1,iy)]
    old_sum = old_sum + 1 if $spin[i] == $spin[p2i(ix-1,iy)]
    old_sum = old_sum + 1 if $spin[i] == $spin[p2i(ix,iy+1)]
    old_sum = old_sum + 1 if $spin[i] == $spin[p2i(ix,iy-1)]

    new_sum = 0
    new_sum = new_sum + 1 if ns == $spin[p2i(ix+1,iy)]
    new_sum = new_sum + 1 if ns == $spin[p2i(ix-1,iy)]
    new_sum = new_sum + 1 if ns == $spin[p2i(ix,iy+1)]
    new_sum = new_sum + 1 if ns == $spin[p2i(ix,iy-1)]
    de = old_sum - new_sum
    $spin[i] = ns if de < 0 or rand() < Math::exp(- beta * de)
  }
end

def export_eps(filename)
  f = open(filename,"w")
  m = 20
  x_offset = 10
  y_offset = 10
  f.puts <<"EOS"
%!PS-Adobe-2.0
%%BoundingBox: 0 0 #{$L*m+x_offset*2} #{$L*m+y_offset*2}
%%EndComments
/mydict 120 dict def
mydict begin
gsave
EOS
  $L.times{|ix|
    $L.times{|iy|
      index = ix + iy * $L
      if $bond_x[index]
        f.puts "#{ix*m + x_offset} #{iy*m + y_offset} moveto"
        f.puts "#{(ix+1)*m + x_offset} #{iy*m + y_offset} lineto stroke"
     end
      if $bond_y[index]
        f.puts "#{ix*m + x_offset} #{iy*m + y_offset} moveto"
        f.puts "#{ix*m + x_offset} #{(iy+1)*m + y_offset} lineto stroke"
     end
      #f.puts "1 1 1 setrgbcolor"
      r,g,b = s2rgb($spin[index])
      f.puts "#{r} #{g} #{b} setrgbcolor"
      f.puts "#{ix*m + x_offset} #{iy*m + y_offset} #{m/4.0} 0 360 arc fill closepath stroke"
      f.puts "0 0 0 setrgbcolor"
      f.puts "#{ix*m + x_offset} #{iy*m + y_offset} #{m/4.0} 0 360 arc closepath stroke"
      f.puts "#{ix*m + x_offset} #{iy*m + y_offset} moveto"
      f.puts "#{ix*m +Math::cos($spin[index])*m/4.0 + x_offset} #{iy*m +Math::sin($spin[index])*m/4.0 + y_offset} lineto stroke"
    }
  }

  f.puts <<"EOS"
grestore
showpage
end
EOS
end

def make_voltex
  $N.times{|i|
    ix = i % $L
    iy = i / $L
    $spin[i] = Math::atan2(iy-$L/2+0.5,ix-$L/2+0.5) + Math::PI*0.5
  }
end

make_voltex()
export_eps("xy_init.eps")
sw_flip(10000.0)
export_eps("xy_sw.eps")
