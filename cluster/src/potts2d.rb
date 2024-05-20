$L = 16
$Q = 4
$N = $L**2
$spin = Array.new($N){(rand()*$Q).to_i}
$bond_x = Array.new($N){false}
$bond_y = Array.new($N){false}
$color = ["1 0 0 ","0 1 0 ","0 0 1 ","0 1 1 "]
$cindex = Array.new($N)

def get_cluster_index(i)
  while i != $cindex[i]
    i = $cindex[i]
  end
  i
end

def connect(i1,i2,beta)
  return false if $spin[i1] != $spin[i2]
  p = 1 - Math::exp(-beta)
  return false if rand() > p  
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

def clustering(beta)
  $N.times{|i|
    $cindex[i] = i
    $bond_x[i] = false
    $bond_y[i] = false
  }
  $N.times{|i|
    ix = i % $L
    iy = (i/$L).to_i
    $bond_x[i] = connect(i,p2i(ix+1,iy),beta)
    $bond_y[i] = connect(i,p2i(ix,iy+1),beta)
  }
end

def sw_flip(beta)
  newspin = Array.new($N){(rand()*$Q).to_i}
  clustering(beta)
  $N.times{|i|
    c = get_cluster_index(i)
    $spin[i] = newspin[c]
  }
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
      f.puts "0 0 0 setrgbcolor"
      if $bond_x[index]
        f.puts "#{ix*m + x_offset} #{iy*m + y_offset} moveto"
        f.puts "#{(ix+1)*m + x_offset} #{iy*m + y_offset} lineto stroke"
     end
      if $bond_y[index]
        f.puts "#{ix*m + x_offset} #{iy*m + y_offset} moveto"
        f.puts "#{ix*m + x_offset} #{(iy+1)*m + y_offset} lineto stroke"
     end
      f.puts "#{$color[$spin[index]]} setrgbcolor"
      f.puts "#{ix*m + x_offset} #{iy*m + y_offset} #{m/4.0} 0 360 arc fill closepath stroke"
    }
  }

  f.puts <<"EOS"
grestore
showpage
end
EOS
end

def make_quad
  $N.times{|i|
    ix = i % $L
    iy = i / $L
    cx = ix * 2 / $L
    cy = iy * 2 / $L
    $spin[i] = cx + cy * 2
  }
end

def sw
make_quad()
10.times{|i|
  filename = sprintf("sw%02d.eps", i)
  export_eps(filename)
  sw_flip(3.0)
}
end

def single
make_quad()
1000.times{|i|
  if (i%10)==0
  filename = sprintf("single%02d.eps", i/10)
  export_eps(filename)
  end
  single_flip(3.0);
}
end

single
sw
