pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- ruby vs all
-- by jojos

function _init()
 sp_ruby={1,2}
 sp_js=5
 sp_sw=6
 sp_bullet=16

 init_stars()
 init_player()
 init_enemies()
 init_bullets()
 init_explosions()
 
 ticks=0
end

function _update60()
 ticks+=1
 
 update_stars()
 update_bullets()
 update_player()
 update_enemies()
 update_explosions()
end

function _draw()
 cls(0)
 
 draw_stars()
 draw_bullets()
 draw_enemies()
 draw_player()
 draw_explosions()

-- draw_score() 
end

function draw_score()
 print("score "..p.s,7)
end

-- utils

function collide(sp1,sp2)
 return sp1.x < sp2.x+8
 and sp1.x+8 > sp2.x
 and sp1.y < sp2.y+8
 and sp1.y+8 > sp2.y
end

-->8
-- player

function init_player()
 p={
  x=128/2-8,
  y=100,
  sp=sp_ruby[1],
  t=1,
  tv=0.1,
  f=0,
  fv=0.2,
  s=0
 }
end

function update_player()
 local nx=p.x
 local ny=p.y
 
 p.f=max(0,p.f-p.fv)
 
 -- spawn enemy for debug
 if btnp(🅾️) then
  spawn_enemy()
 end
 
 if btn(❎) and p.f==0 then
  fire()
  sfx(0)
  p.f=1
 end
 if btn(⬅️) then
  nx-=1
 end
 if btn(➡️) then
  nx+=1
 end
 if btn(⬆️) then
  ny-=1
 end
 if btn(⬇️) then
  ny+=1
 end
 
 p.x=mid(0,nx,128-8)
 p.y=mid(0,ny,128-8)
end

function draw_player()
 spr(p.sp,p.x,p.y)
end
-->8
-- bullets

function init_bullets()
 bullets={}
end

function update_bullets()
 for b in all(bullets) do
  b.x+=b.vx
  b.y+=b.vy
  
  if b.x<0 or b.x>128
  or b.y<0 or b.y>128
  then
   del(bullets,b)
  end
 end
end

function draw_bullets()
 for b in all(bullets) do
  spr(b.sp,b.x,b.y)
 end
end

function fire()
 local b={
  sp=sp_bullet,
  x=p.x,
  y=p.y,
  vx=0,
  vy=-3,
  d=1
 }
 
 add(bullets,b)
end
-->8
-- ennemies

function init_enemies()
 enemies={}
 e_prop={
  js={sp=sp_js,l=4,s=1},
  sw={sp=sp_sw,l=6,s=2},
 }
end

function spawn_enemy()
 local et
 
 if rnd(2) < 1 then
  et=e_prop.js
 else
  et=e_prop.sw
 end
 
 local e={
  sp=et.sp,
  x=rnd(128),
  y=0,
  l=et.l,
  s=et.s
 }
 
 add(enemies, e)
end

function update_enemies()
 -- enemy is alive
 for e in all(enemies) do
   
  -- hit bullets
  for b in all(bullets) do
   if collide(b,e) then
    sfx(1)
    e.l-=b.d
    del(bullets,b)
   end
  end

  if e.l<=0 then
   sfx(2)
   explode(e.x+8/2,e.y+8/2)
   del(enemies, e)
   p.s+=e.s
  end
 end
end

function draw_enemies()
 for e in all(enemies) do
  spr(e.sp,e.x,e.y)
 end
end
-->8
-- stars

function init_stars()
 stars={
  std={},
  alt={}
 }
 
 s_props={
  c=7,
  c_a=5,
  v=0.25,
  v_a=0.03,
  m=90,
  m_a=50
 }
 
 for i=1,s_props.m do
  local star=spawn_star(false)
  star.y=rnd(128)
 end
 for i=1,s_props.m_a do
  local star=spawn_star(true)
  star.y=rnd(128)
 end
end

function update_stars()
 for r,st in pairs(stars) do
  for s in all(st) do
	  s.y+=s.v
	  
	  if s.y>128 then
	   del(st,s)
	   spawn_star(s.alt)
	  end
	 end
 end
end

function spawn_star(alt)
 local v=s_props.v
 local c=s_props.c
 local r=stars.std
 
 if alt then
  v=s_props.v_a
  c=s_props.c_a
  r=stars.alt
 end
 
 local st={
  x=flr(rnd(128)),
  y=-1,
  w=0.5,
  h=0.5,
  v=v,
  c=c,
  alt=alt
 }
 
 add(r,st)
 
 return st
end

function draw_stars()
 for r,st in pairs(stars) do
  for s in all(st) do
	  rectfill(
	   s.x, s.y,
	   s.x+s.w, s.y+s.h,
	   s.c
	  )
  end
 end
end
-->8
-- explosions

function init_explosions()
 explosions={}
end

function update_explosions()
 for e in all(explosions) do
  e.r+=e.f
  
  if ticks%30<15 then
   e.c=8
  else
  	e.c=9
  end
  
  if e.r>5 then
   del(explosions,e)
  end  
 end
end

function draw_explosions()
 for e in all(explosions) do
  circ(e.x,e.y,e.r,e.c)
 end
end

function explode(x,y)
 local ex={
  x=x,y=y,
  r=1,
  c=8,
  f=0.25
 }
 
 add(explosions,ex)
end
__gfx__
00000000000000000000000000000000000000005555500000007000000000000000000000000000000000000000000000000000000000000000000000000000
00000000088888800888888000000000000000000050000000700070000000000000000000000000000000000000000000000000000000000000000000000000
007007008e888ee88888888800000000000000000050555507777777000000000000000000000000000000000000000000000000000000000000000000000000
000770008ee888888888888800000000000000000050500077777700000000000000000000000000000000000000000000000000000000000000000000000000
0007700008ee8ee00888888000000000000000005550555577777700000000000000000000000000000000000000000000000000000000000000000000000000
007007000888ee800888888000000000000000000000000577777777000000000000000000000000000000000000000000000000000000000000000000000000
00000000008888000088880000000000000000000000555507777770000000000000000000000000000000000000000000000000000000000000000000000000
00000000000880000008800000000000000000000000000000777700000000000000000000000000000000000000000000000000000000000000000000000000
00033000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00033000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00033000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100001c7501c7501c7501c7501a75018750177501470014700176001660014600116000f6000e600000002020024200272002920024500275002a5002c5002d50027300263000000000000000000000000000
000100002615023150211501f1501e1501d1501c15000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002365025650286502a6502a65028650226501e6501a650186501664015640126300f6300d6200000000000000000000000000000000000000000000000000000000000000000000000000000000000000
