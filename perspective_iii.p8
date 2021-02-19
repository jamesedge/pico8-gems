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

-- multiplies a 4x4 matrix with a 4 element column vector
function m4mulv4(m, v)
  return {
    m[1]*v[1]+m[2]*v[2]+m[3]*v[3]+m[4]*v[4],
    m[5]*v[1]+m[6]*v[2]+m[7]*v[3]+m[8]*v[4],
    m[9]*v[1]+m[10]*v[2]+m[11]*v[3]+m[12]*v[4],
    m[13]*v[1]+m[14]*v[2]+m[15]*v[3]+m[16]*v[4]
  }
end

-- returns the perspective matrix for a given field of view
function perspective(fov)
  s=cotangent(fov/2)
  return {
    s, 0, 0, 0,
    0, s, 0, 0,
    0, 0, 1, 0,
    0, 0, -1, 0
  }
end

--[[ code ]]--

xoff, yoff, fov=0, 0, 90

::_::
cls()

-- update offset
xoff+=(btn(1) and 0.1 or 0)-(btn(0) and 0.1 or 0)
yoff+=(btn(2) and 0.1 or 0)-(btn(3) and 0.1 or 0)
-- update fov
fov=mid(10, fov+(btn(4) and 5 or 0)-(btn(5) and 5 or 0), 180)
proj=perspective(fov)

-- project points
ppoints={}
foreach(points, function(point)
  p=m4mulv4(proj, { point[1]+xoff, point[2]+yoff, point[3], 1 }) -- to clip coordinates
  p[1]/=p[4] p[2]/=p[4] p[3]/=p[4] -- perspective divide by w
  add(ppoints, { 64*p[1]+64, 64-64*p[2] }) -- screen space
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
text('projection matrix:', 1, 13)
text(twodp(proj[1])..', '..twodp(proj[2])..', '..twodp(proj[3])..', '..twodp(proj[4]), 1, 19)
text(twodp(proj[5])..', '..twodp(proj[6])..', '..twodp(proj[7])..', '..twodp(proj[8]), 1, 25)
text(twodp(proj[9])..', '..twodp(proj[10])..', '..twodp(proj[11])..', '..twodp(proj[12]), 1, 31)
text(twodp(proj[13])..', '..twodp(proj[14])..', '..twodp(proj[15])..', '..twodp(proj[16]), 1, 37)
text('\139\145\148\131: move (x,y)', 1, 116)
text('\142\151: change field of view', 1, 122)

flip()
goto _
