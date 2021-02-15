pico-8 cartridge // http://www.pico-8.com
version 29
__lua__

--[[ data ]]--

-- cube points
points={
  { -1, -1, -2 },
  {  1, -1, -2 },
  {  1,  1, -2 },
  { -1,  1, -2 },
  { -1, -1, -4 },
  {  1, -1, -4 },
  {  1,  1, -4 },
  { -1,  1, -4 }
}
-- cube faces
faces={
 { 5, 6, 7, 8 },
 { 2, 3, 7, 6 },
 { 1, 2, 6, 5 },
 { 1, 4, 3, 2 },
 { 1, 5, 8, 4 },
 { 3, 4, 8, 7 }
}

--[[ functions ]]--

-- draw text with a shadow
function text(t, x, y)
  print(t, x, y+1, 5)
  print(t, x, y, 7)
end

-- round x to 2 decimal places
function twodp(x) return x*100\1/100 end

--[[ code ]]--

-- offsets
xoff, yoff, zoff=0, 0, 0

::_::
cls(0)

-- update offsets
xoff+=(btn(1) and 0.1 or 0)-(btn(0) and 0.1 or 0)
yoff+=(btn(2) and 0.1 or 0)-(btn(3) and 0.1 or 0)
zoff=mid(-20, zoff+(btn(4) and 0.1 or 0)-(btn(5) and 0.1 or 0), 1.5)

-- project points
ppoints={}
foreach(points, function(point)
  x, y, z=point[1]+xoff, point[2]+yoff, point[3]+zoff
  w=-z
  px, py=x/w, y/w -- clip space
  add(ppoints, { 64*px+64, 64-64*py }) -- screen space
end)

-- draw faces
color(8)
foreach(faces, function(face)
  np=#face
  -- draw each edge
  for i=1,np do
    p1, p2=ppoints[face[i]], ppoints[face[i%np+1]]
    line(p1[1], p1[2], p2[1], p2[2])
  end
end)

text('offset: '..twodp(xoff)..', '..twodp(yoff)..', '..twodp(zoff), 1, 1)
text('\139\145\148\131\142\151: move cube (x,y,z)', 1, 122)

flip()
goto _
