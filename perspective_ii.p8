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

-- cosine function converts degrees to pico8 turns
function cosine(a) return cos(a/360) end
-- sine function converts degrees to pico8 turns
function sine(a) return sin(-a/360) end
-- cotangent function = 1/tan
function cotangent(a) return cosine(a)/sine(a) end

--[[ code ]]--

xoff, yoff, fov=0, 0, 90

::_::
cls()

-- update offset
xoff+=(btn(1) and 0.1 or 0)-(btn(0) and 0.1 or 0)
yoff+=(btn(2) and 0.1 or 0)-(btn(3) and 0.1 or 0)
-- update fov
fov=mid(10, fov+(btn(4) and 5 or 0)-(btn(5) and 5 or 0), 180)
s=cotangent(fov/2) -- 1/tan(fov/2)

printh(s)
-- project points
ppoints={}
foreach(points, function(point)
  x, y, z=point[1]+xoff, point[2]+yoff, point[3]
  w=-point[3]
  px, py=(s*x)/w, (s*y)/w -- clip space
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

text('offset: '..twodp(xoff)..', '..twodp(yoff), 1, 1)
text('fov: '..twodp(fov)..' degrees', 1, 7)
text('\139\145\148\131: move (x,y)', 1, 116)
text('\142\151: change field of view', 1, 122)

flip()
goto _
