pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- ruby vs all
-- by jojos

#include tools.lua

function _init()
 sp_ruby={1,2,3}
 sp_bullet=16

 init_sprites()

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

 update_sprites()
end

function _draw()
 cls(0)
 
 draw_stars()
 draw_sprites()
 draw_explosions()

 draw_score()
end

function draw_score()
 print("score "..player.score,7)
end

-->8
-- player

function init_player()
 player=build_sprite()

 player.x=128/2-8
 player.y=100
 player.dx=player.x
 player.dy=player.y
 player.f=0 -- fire
 player.fv=0.2 -- fire vel
 player.score=0

 -- idle anim
 local anim=build_anim()
 anim.v=0.1
 anim_add_frame(anim,sp_ruby[1])
 anim_add_frame(anim,sp_ruby[2])
 anim_add_frame(anim,sp_ruby[3])
 player.anims[1]=anim

 add_sprite(player)
end

function update_player()
 local nx=player.x
 local ny=player.y
 
 player.f=max(0,player.f-player.fv)
 
 -- spawn enemy for debug
 -- if btnp(🅾️) then
 --  spawn_enemy()
 -- end
 
 if btn(❎) and player.f==0 then
  fire()
  sfx(0)
  player.f=1
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
 
 player.x=mid(0,nx,128-8)
 player.y=mid(0,ny,128-8)
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
   remove_bullet(b)
  end
 end
end

function remove_bullet(b)
 del(bullets,b)
 remove_sprite(b)
end

function fire()
 local b=build_sprite()

 b.x=player.x
 b.y=player.y
 b.vx=0
 b.vy=-3
 b.damage=1

 local anim=build_anim()
 anim_add_frame(anim,sp_bullet)
 b.anims[1]=anim

 add_sprite(b)
 add(bullets,b)
end
-->8
-- ennemies

function init_enemies()
 enemies={}

 max_enemies=15

 e_prop={
  {
   n="swift",
   sp=6,
   v=0.35,
   life=6,
   score=10,
   freq=0.25
  },
  {
   n="js",
   sp=5,
   v=0.50,
   life=4,
   score=5,
   freq=0.50
  },
  {
   n="php",
   sp=7,
   v=0.75,
   life=1,
   score=1,
   freq=0.75
  }
 }
end

function spawn_enemy()
 local et=e_prop[#e_prop]
 
 local rng=rnd(100)/100
 for v in all(e_prop) do
  if v.freq > rng then
   et=v
   break
  end
 end
 
 local e=build_sprite()

 e.x=rnd(128)
 e.y=0
 e.life=et.life
 e.score=et.score
 e.v=et.v

 local anim=build_anim()
 anim_add_frame(anim,et.sp)
 e.anims[1]=anim
 
 add_sprite(e)
 add(enemies, e)
end

function update_enemies()
 -- need to spawn enemy?
 if #enemies<max_enemies and ticks%30==0 then
  spawn_enemy()
 end

 for e in all(enemies) do
  -- hit enemy
  for b in all(bullets) do
   if sprites_collide(b,e) then
    sfx(1)
    e.life-=b.damage
    remove_bullet(b)
   end
  end

  -- kill enemy
  if e.life<=0 then
   sfx(2)
   explode(e.x+e.w/2,e.y+e.h/2)
   remove_enemy(e)
   player.score+=e.score
  end

  -- move enemy
  if e.life>0 then
   e.y+=e.v
  end

  -- out of map
  if e.y>128 then
   remove_enemy(e)
  end
 end
end

function remove_enemy(e)
 del(enemies, e)
 remove_sprite(e)
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
00000000000000000000000000000000000000009999900000006000111000000000000000000000000000000000000000000000000000000000000000000000
00000000088888800888888008888880000000000090000000600060101000000000000000000000000000000000000000000000000000000000000000000000
007007008e8888888e888ee88e888ee800000000009099990666666611c0c0000000000000000000000000000000000000000000000000000000000000000000
00077000888888888e8888888ee8888800000000009090006666660010ccc0000000000000000000000000000000000000000000000000000000000000000000
0007700008e888e008ee88e008ee8ee000000000999099996666660010c0c1110000000000000000000000000000000000000000000000000000000000000000
007007000888e8800888ee800888ee8000000000000000096666666600c0c1010000000000000000000000000000000000000000000000000000000000000000
00000000008888000088880000888800000000000000999906666660000001110000000000000000000000000000000000000000000000000000000000000000
00000000000880000008800000088000000000000000000000666600000001000000000000000000000000000000000000000000000000000000000000000000
00033000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00033000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00033000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100001c7501c7501c7501c7501a75018750177501470014700176001660014600116000f6000e600000002020024200272002920024500275002a5002c5002d50027300263000000000000000000000000000
000100002615023150211501f1501e1501d1501c15000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002365025650286502a6502a65028650226501e6501a650186501664015640126300f6300d6200000000000000000000000000000000000000000000000000000000000000000000000000000000000000
