pico-8 cartridge // http://www.pico-8.com
version 29
__lua__

--[[ data ]]--

-- cube points
points={
  { -1, -1,  1,  1 },
  {  1, -1,  1,  1 },
  {  1,  1,  1,  1 },
  { -1,  1,  1,  1 },
  { -1, -1, -1,  1 },
  {  1, -1, -1,  1 },
  {  1,  1, -1,  1 },
  { -1,  1, -1,  1 }
}
-- cube faces
faces={
 { 5, 6, 7, 8, color=9 },
 { 2, 3, 7, 6, color=10 },
 { 1, 2, 6, 5, color=11 },
 { 1, 4, 3, 2, color=12 },
 { 1, 5, 8, 4, color=13 },
 { 3, 4, 8, 7, color=14 }
}

--[[ functions ]]--

-- draw text with a shadow
function text(t, x, y)
  print(t, x, y+1, 5)
  print(t, x, y, 7)
end

-- round x to 2 decimal places
function twodp(x) return x*100\1/100 end

-- round x to the nearest whole number
function round(x) return flr(x+0.5) end

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

-- multiplies two 4x4 matrices
function m4mulm4(m1, m2)
  return {
    m1[1]*m2[1]+m1[2]*m2[5]+m1[3]*m2[9]+m1[4]*m2[13],
    m1[1]*m2[2]+m1[2]*m2[6]+m1[3]*m2[10]+m1[4]*m2[14],
    m1[1]*m2[3]+m1[2]*m2[7]+m1[3]*m2[11]+m1[4]*m2[15],
    m1[1]*m2[4]+m1[2]*m2[8]+m1[3]*m2[12]+m1[4]*m2[16],
    m1[5]*m2[1]+m1[6]*m2[5]+m1[7]*m2[9]+m1[8]*m2[13],
    m1[5]*m2[2]+m1[6]*m2[6]+m1[7]*m2[10]+m1[8]*m2[14],
    m1[5]*m2[3]+m1[6]*m2[7]+m1[7]*m2[11]+m1[8]*m2[15],
    m1[5]*m2[4]+m1[6]*m2[8]+m1[7]*m2[12]+m1[8]*m2[16],
    m1[9]*m2[1]+m1[10]*m2[5]+m1[11]*m2[9]+m1[12]*m2[13],
    m1[9]*m2[2]+m1[10]*m2[6]+m1[11]*m2[10]+m1[12]*m2[14],
    m1[9]*m2[3]+m1[10]*m2[7]+m1[11]*m2[11]+m1[12]*m2[15],
    m1[9]*m2[4]+m1[10]*m2[8]+m1[11]*m2[12]+m1[12]*m2[16],
    m1[13]*m2[1]+m1[14]*m2[5]+m1[15]*m2[9]+m1[16]*m2[13],
    m1[13]*m2[2]+m1[14]*m2[6]+m1[15]*m2[10]+m1[16]*m2[14],
    m1[13]*m2[3]+m1[14]*m2[7]+m1[15]*m2[11]+m1[16]*m2[15],
    m1[13]*m2[4]+m1[14]*m2[8]+m1[15]*m2[12]+m1[16]*m2[16]
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

-- returns the transformation matrix for the translation (tx, ty, tz)
function translate(tx, ty, tz)
  return {
    1, 0, 0, tx,
    0, 1, 0, ty,
    0, 0, 1, tz,
    0, 0, 0, 1
  }
end

-- returns the transformation matrix for a rotation around the x axis
function rotate_x(a)
  local ca, sa = cosine(a), sine(a)
  return {
    1, 0, 0, 0,
    0, ca, -sa, 0,
    0, sa, ca, 0,
    0, 0, 0, 1
  }
end

-- returns the transformation matrix for a rotation around the y axis
function rotate_y(a)
  local ca, sa = cosine(a), sine(a)
  return {
    ca, 0, sa, 0,
    0, 1, 0, 0,
    -sa, 0, ca, 0,
    0, 0, 0, 1
  }
end

-- returns the transformation matrix for a rotation around the z axis
function rotate_z(a)
  local ca, sa = cosine(a), sine(a)
  return {
    ca, -sa, 0, 0,
    sa, ca, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1
  }
end

-- fill a polygon
function fill_polygon(poly)
  color(poly.color) -- set colour
  local scan, prev={}, poly[#poly] -- scan stores the scanline endpoints, prev is the previous point
  -- for each point
  foreach(poly, function(next)
    local x0, y0, x1, y1, x=prev[1], round(prev[2]), next[1], round(next[2]) -- get coordinates for edge
    if (y1<y0) x0, y0, x1, y1=x1, y1, x0, y0 -- switch coordinates so that y0<y1
    local dx=(x1-x0)/(y1-y0) -- dx/dy for the edge

    -- clip to screen edge
    if (y0<0) y0, x0=0, x0-y0*dx

    -- for each scanline in the edge
    for y=y0,min(y1,127) do
      if scan[y] then rectfill(x0, y, scan[y], y) -- if we have the endpoint for this scanline, fill the line
      else scan[y]=x0 end -- otherwise store an endpoint
      x0+=dx -- update x
    end

    prev=next -- keep track of previous point
  end)
end

--[[ code ]]--

xang, yang, cullface, zoff, fov=0, 0, true, -5, 45

::_::
cls()

-- update offset
xang+=1
yang-=1
-- update cullface
if (btnp(4)) cullface=not cullface

proj=perspective(fov) -- perspective projection
mv=translate(0, 0, zoff) -- modelview matrix, translate the object
mv=m4mulm4(mv, rotate_x(xang)) -- rotate around x axis
mv=m4mulm4(mv, rotate_y(yang)) -- rotate around y axis
mvp=m4mulm4(proj, mv) -- modelview-projection matrix

-- project points
ppoints={}
foreach(points, function(point)
  p=m4mulv4(mvp, point) -- to clip coordinates
  p[1]/=p[4] p[2]/=p[4] p[3]/=p[4] -- perspective divide by w
  p[1], p[2]= 64*p[1]+64, 64-64*p[2] -- to screen coordinates
  add(ppoints, p)
end)

-- fill polygons
foreach(faces, function(face)
  v1, v2, v3, v4=ppoints[face[1]], ppoints[face[2]], ppoints[face[3]], ppoints[face[4]]
  -- if cullface is true, checks that face is front facing before drawing
  if not cullface or (v2[1]-v1[1])*(v3[2]-v1[2])-(v2[2]-v1[2])*(v3[1]-v1[1])>0 then
    poly={ v1, v2, v3, v4, color=face.color }
    fill_polygon(poly)
  end
end)

text('cullface: '..(cullface and 'on' or 'off'), 1, 1)
text('modelview-projection matrix:', 1, 7)
text(twodp(mvp[1])..', '..twodp(mvp[2])..', '..twodp(mvp[3])..', '..twodp(mvp[4]), 1, 13)
text(twodp(mvp[5])..', '..twodp(mvp[6])..', '..twodp(mvp[7])..', '..twodp(mvp[8]), 1, 19)
text(twodp(mvp[9])..', '..twodp(mvp[10])..', '..twodp(mvp[11])..', '..twodp(mvp[12]), 1, 25)
text(twodp(mvp[13])..', '..twodp(mvp[14])..', '..twodp(mvp[15])..', '..twodp(mvp[16]), 1, 31)
text('\142: toggle cullface', 1, 122)

flip()
goto _
