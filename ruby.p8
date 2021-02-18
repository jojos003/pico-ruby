pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- ruby vs all
-- by jojos

#include tools.lua

function _init()
 cartdata("jojos003_pico-ruby_1")

 ticks=0

 sp_ruby={1,2,3,4}
 sp_bullet=16

 max_enemies=20

 colors_prop={
  bg=0,
  txt=14
 }

 -- catridge memory properties
 m_prop={
  hs=0 -- memory address for high score
 }

 -- game properties
 g_prop={
  x=0,
  w=128,
  y=0,
  h=128,
  ls=true -- lifes should be shown?
 }

 p_prop={
  life=3, -- lifes
  fv=0.2, -- fire velocity
  cd=2*60 -- 2s of cooldown after hit ; 60 is fps/s
 }

 e_prop={
  {
   n="sw",
   sp=6,
   v=0.35,
   life=10,
   score=9,
   freq=0.25
  },
  {
   n="kt",
   sp=10,
   v=0.27,
   life=13,
   score=10,
   freq=0.28
  },
  {
   n="cs",
   sp=8,
   v=0.48,
   life=8,
   score=8,
   freq=0.30
  },
  {
   n="ts",
   sp=9,
   v=0.60,
   life=7,
   score=5,
   freq=0.45
  },
  {
   n="js",
   sp=5,
   v=0.50,
   life=3,
   score=3,
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

 s_props={
  c=7,
  c_a=5,
  v=0.25,
  v_a=0.03,
  m=40,
  m_a=20
 }

 scenes={
  title={
   init=init_title,
   update=update_title,
   draw=draw_title
  },
  game={
   init=init_game,
   update=update_game,
   draw=draw_game
  },
  over={
   init=init_over,
   update=update_over,
   draw=draw_over
  }
 }

 blink={
  visible=true,
  f=0,    -- current frame
  vt=30,  -- visible time
  ht=10   -- hide time
 }

 high_score=dget(m_prop.hs)

 init_stars()

 switch_scene("title")
end

function _update60()
 ticks+=1

 update_blink()

 scenes[current_scene].update()
end

function _draw()
 scenes[current_scene].draw()
end

function draw_score()
 print("score "..player.score,7)

 if g_prop.ls then
  for l=0,player.life-1 do
   spr(3,l*player.w+l*2,8)
  end
 end
end

function update_blink()
 blink.f-=1

 if (blink.f>0) return

 if blink.visible then
   blink.visible=false
   blink.f=blink.ht
 else
   blink.visible=true
   blink.f=blink.vt
 end
end

-->8
-- scenes

function switch_scene(scene)
 current_scene=scene
 scenes[current_scene].init()
end

function init_title()
 init_sprites()
 init_player()
end

function update_title()
 if btnp(🅾️) then
  switch_scene("game")
 end

 update_stars()
 update_sprites()
end

function draw_title()
 cls(colors_prop.bg)

 draw_stars()

 color(colors_prop.txt)

 if blink.visible then
  str="press 🅾️ to start"
  tx=(g_prop.w/2)-(#str*4/2)
  ty=20
  print(str,tx,ty)
 end

 if high_score>0 then
  str="high score"
  tx=(g_prop.w/2)-(#str*4/2)
  ty=40
  print(str,tx,ty)

  str=tostr(high_score)
  tx=(g_prop.w/2)-(#str*4/2)
  ty+=10
  print(str,tx,ty)
 end

 draw_sprites()
end

function init_game()
 init_enemies()
 init_bullets()
 init_explosions()
end

function update_game()
 update_stars()
 update_bullets()
 update_player()
 update_enemies()
 update_explosions()

 update_sprites()
end

function draw_game()
 cls(colors_prop.bg)
 
 draw_stars()
 draw_sprites()
 draw_explosions()

 draw_score()
end

function init_over()
 if bullets then
  for b in all(bullets) do
   remove_bullet(b)
  end
 end

 over_enemies_screener={
  f_enemy_prop('sw'),
  f_enemy_prop('cs'),
  f_enemy_prop('ts'),
  f_enemy_prop('js'),
  f_enemy_prop('ts'),
  f_enemy_prop('cs'),
  f_enemy_prop('sw')
 }
end

function update_over()
 if btnp(🅾️) then
  switch_scene("title")
 end

 update_stars()
end

function draw_over()
 cls(colors_prop.bg)
 
 draw_stars()

 color(0)

 local rec={x1=10,y1=15,x2=118,y2=105}
 rectfill(rec.x1-2,rec.y1-2,rec.x2+2,rec.y2+2,7)
 rectfill(rec.x1,rec.y1,rec.x2,rec.y2,0)

 color(colors_prop.txt)

 local str, tx, ty

 str="you failed against boring"
 tx=(g_prop.w/2)-(#str*4/2)
 ty=20
 print(str,tx,ty)

 str="and sad languages!"
 tx=(g_prop.w/2)-(#str*4/2)
 ty+=10
 print(str,tx,ty)

 str="shame on you"
 tx=(g_prop.w/2)-(#str*4/2)
 ty+=10
 print(str,tx,ty)

 str="your poor score is "
 tx=(g_prop.w/2)-(#str*4/2)
 ty=60
 print(str,tx,ty)

 str=tostr(player.score)
 tx=(g_prop.w/2)-(#str*4/2)
 ty+=10
 print(str,tx,ty)

 local en=over_enemies_screener
 tx=(g_prop.w/2)-(12*#en/2)

 for i,e in pairs(en) do
  local o=(i-1)*12

  spr(e.sp,tx+o,90)
  spr(e.sp,tx+o,90)
  spr(e.sp,tx+o,90)
 end

 color()
end

-->8
-- player

function init_player()
 player=build_sprite()

 player.x=g_prop.w/2-8
 player.y=100
 player.dx=player.x
 player.dy=player.y
 player.f=0 -- fire
 player.fv=p_prop.fv -- fire vel
 player.score=0
 player.life=p_prop.life
 player.state=1

 -- idle anim
 local anim=build_anim()
 anim.v=0.1
 anim_add_frame(anim,sp_ruby[1])
 anim_add_frame(anim,sp_ruby[2])
 anim_add_frame(anim,sp_ruby[3])
 player.anims[1]=anim

 -- blink anim
 local anim=build_anim()
 anim.v=0.25
 anim_add_frame(anim,sp_ruby[1])
 anim_add_frame(anim,sp_ruby[4])
 anim_add_frame(anim,sp_ruby[2])
 anim_add_frame(anim,sp_ruby[4])
 anim_add_frame(anim,sp_ruby[3])
 anim_add_frame(anim,sp_ruby[4])
 player.anims[2]=anim

 add_sprite(player)
end

function update_player()
 local nx=player.x
 local ny=player.y
 
 player.f=max(0,player.f-player.fv)
 
 -- cooldown?
 if player.state==2 then
  player.cd-=1 -- decrement cooldown at each tick
  if player.cd<=0 then
   sprite_set_state(player,1)
  end
 end

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
 
 player.x=mid(g_prop.x,nx,g_prop.w-8)
 player.y=mid(g_prop.y,ny,g_prop.h-8)
end

function player_hit()
 sfx(3)
 explode(player.x+player.w/2,player.y+player.h/2)

 player.cd=p_prop.cd
 player.life-=1

 if player.life>0 then
  sprite_set_state(player,2)
 else
  if player.score>high_score then
   high_score=player.score
   dset(m_prop.hs,high_score)
  end

  switch_scene("over")
 end
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
  
  if b.x<0 or b.x>g_prop.w
  or b.y<0 or b.y>g_prop.h
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
end

function spawn_enemy(et,x,y)
 local e=build_sprite()

 e.n=et.n
 e.x=x
 e.y=y
 e.life=et.life
 e.score=et.score
 e.v=et.v

 local anim=build_anim()
 anim_add_frame(anim,et.sp)
 e.anims[1]=anim
 
 add_sprite(e)
 add(enemies, e)
end

function next_enemies()
 local et=e_prop[#e_prop]

 local rng=rnd(100)/100
 for v in all(e_prop) do
  if v.freq > rng then
   et=v
   break
  end
 end

 return et
end

function update_enemies()
 -- need to spawn enemy?
 if #enemies<max_enemies and ticks%25==0 then
  for i=0,rnd(4) do
   local e=next_enemies()
   local x=mid(0,rnd(g_prop.w),g_prop.w-8)
   local y=0

   spawn_enemy(e,x,y)
  end
 end

 for e in all(enemies) do
  -- hit by enemy
  -- only when player not in cooldown
  if player.state!=2 and sprites_collide(e,player) then
   remove_enemy(e)
   player_hit()

   -- let some breath
   break
  end

  -- bullet hit enemy
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
   enemy_died(e)
   player.score+=e.score
  end

  -- move enemy
  if e.life>0 then
   e.y+=e.v
  end

  -- out of map
  if e.y>g_prop.w then
   remove_enemy(e)
  end
 end
end

function remove_enemy(e)
 del(enemies, e)
 remove_sprite(e)
end

function enemy_died(e)
 if e.n=='ts' then
  local js=f_enemy_prop('js')

  local x=mid(0,e.x+10,258-8)
  local y=max(0,e.y-20)
  spawn_enemy(js,x,y)

  local x=mid(0,e.x-10,258-8)
  local y=max(0,e.y-20)
  spawn_enemy(js,x,y)
 end
end

function f_enemy_prop(name)
 for et in all(e_prop) do
  if et.n==name then
   return et
  end
 end
end
-->8
-- stars

function init_stars()
 stars={
  std={},
  alt={}
 }
 
 for i=1,s_props.m do
  local star=spawn_star(false)
  star.y=rnd(g_prop.w)
 end
 for i=1,s_props.m_a do
  local star=spawn_star(true)
  star.y=rnd(g_prop.w)
 end
end

function update_stars()
 for r,st in pairs(stars) do
  for s in all(st) do
	  s.y+=s.v
	  
	  if s.y>g_prop.w then
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
  x=flr(rnd(g_prop.w)),
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
00000000000000000000000000000000000000009999900000006000111000000bbb000011111000cccc99900000000000000000000000000000000000000000
0000000008888880088888800888888000000000009000000060006010100000b000000000100000ccc999000000000000000000000000000000000000000000
007007008e8888888e888ee88e888ee800000000009099990666666611c0c000b000202000101111cc9990000000000000000000000000000000000000000000
00077000888888888e8888888ee8888800000000009090006666660010ccc000b002222200101000c99900000000000000000000000000000000000000000000
0007700008e888e008ee88e008ee8ee000000000999099996666660010c0c1110bbb202000101111999cc0000000000000000000000000000000000000000000
007007000888e8800888ee800888ee8000000000000000096666666600c0c101000222220000000199cccc000000000000000000000000000000000000000000
000000000088880000888800008888000000000000009999066666600000011100002020000011119cccccc00000000000000000000000000000000000000000
00000000000880000008800000088000000000000000000000666600000001000000000000000000000000000000000000000000000000000000000000000000
00033000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00033000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00033000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
07700770077077707770000077007770000000500000000000000000000000000000000070000000000000000000000000000000000000000000000000000000
70007000707070707000000007000070000000500000000000000000000000000000000070000000000000000000000000000000000000000000000000000000
77707000707077007700000007007770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00707000707070707000000007007000000000000000700000000000005000000000000000000000000000000000500070000000000000000000000000000000
77000770770070707770000077707770000000000070000000000000000000000000000000000070000000000000000070000000000000000000000000000000
00000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000070000000000000000000
00000000000000000000000000000000000000000000000000000000011100000000700000000000000000000000000000000700000000000000000000000007
00000000000000000000000000000000000000700000000000000000010100000000700000000000000000000000000000000700000000000000000000000007
00000000000000000000000000000000000000700000000000000000011c0c000000000000000000000000000000000000000000000000000000000000000000
08888880000888888000088888800000000000000000000000000000010ccc000000000000000000000000000000000000000000000000000000000000000000
8e888ee8008e888ee8008e888ee80000000000000000000000000000010c0c111000000000000000000000000007000000000000000000000000000000000000
8ee88888008ee88888008ee888880000000000000000000000000000007c0c101000000000000000000000000007000000000000000000000000000000000000
08ee8ee00008ee8ee00008ee8ee00000000330000000000000000000000000111000000000000050000000000000000000000000000000000000000000000000
0888ee80060888ee80000888ee800000000330000000000000000000000000100000000000000050000000000000000000000000000000000000000000000000
00888806000688880000008888000000000330000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000
00088066666668800000000880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007000000000000
00000666666000000000000000000000000500000000000000000000000000000000000000000000000000000000000070000000000000000007000000000000
00000666666660000000000000000000000000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000
00000066666600000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000
00000006666000000000000000000000050000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000070000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000500000000000
00000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000500000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000007000000000000000000000
00000000000000000000000000000000000070000000000000000000000000500000000000000000000000000000000000000000007000000000000000000000
50000000000000000000000000000000000070000000000000000000007000500000000000000000000000000000000000000000000000000000007000000000
50000000070050000000000000000000000330000000000000000000000000000000000000000000000000000000000000000000000500000000007000000000
00000000000000000000000000000000000330000000700000000000000000000000000000000000000000000000000000000000000500000000000000000000
00000000000000000000000000000000000330000000700000000000000000000000000000000000000000000005000000000000000000000000000000000000
00000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000050000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000050000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000500000000000000000000000000000000000000000000000000000
00000000007000000000000000000000000000000000000000000000000000000000000000500000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000
00000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007000000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000050000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000000000000000000000000
00000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000007000000005000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000005070000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000003300000000000000000000000000000000000000000000000000000000000000000000500000000000000000000
00000000000000000000000000000000000003300000000000000000000000000000000000000000000000000700000000000000000500000000000000000000
00000000000000000000000000000000000003300000000000000000000000000000000000000000000000000700000000000000000000000000000000000000
00000000000700000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000500000000000000000000000
00000000000700000000070000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000
00000000000000000000070000000007000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00007000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000500000000000000000500000000000
00007000000000000000000000000000000000000000000000007000000000000000000000000000700000000000000000000000000000000000500000000000
00000000000000000700000000000000000000000000000000007000000000000000000000000000700000000000000000000000000000000000000000000000
00000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000070000500000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000500000000000000500000000007000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000500000000007000000000000
00000000000000000000000005000000000000000003300000000000000000000000000000000000000000000007000000000000000006000000000000000000
00000000000000000000000005000000000000000003300000000000000000000000000000000000000000000007000000000000000600060000000000000000
00000000000000000000000000000000000000000003300000000000000000000000000000700000000000000000000000000000006666666000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000000000007000066666600000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066666600000000000000000
00000000000000000000000000000000000000000000000000000000000500000000000000000000000000000000000000000000066666666000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006666660000000000000000
00000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000666600000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000001110000000000000000000000000000000000000000000000000
00000000000000000000070000000000000000000000000000000000000000000000000000001010000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000011c0c00000000007000000000000000000000000000000007000
000000000000000000000000000000000000000000000000000000005000000000000000000010ccc00000000000000000000000000000000000000000050000
000000000000000000000000000000000000000005000000000000000000000000000007000010c0c11100000000000000070000000000000000000000000000
000000000000000000000000000000000000000005000000000000000000000000000000000000c0c10100000000000000070000000000000000000000000000
00000000000000000500000000000000000000000000000000000000000000000000000000000000011100000000000000000000000000000000000000000000
00000000000000000500000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000007000000000000000000000000000
00000000000000000000000000000000000000000000000003300000000000000000000070000000000000000000000000077000000000000000000000000000
00000000000000000000000000000000000000000000000003300000000000000000000000000000000000000700000000000000000000000000000000000000
00000000000000000000000000000000000000000000000003300000000000000000070000000000000000000700000000000000000000000000000000000700
00000700000000000000000000000000000000000000700000000000000000000000070000000000000000000000000000000000700000000000000000000000
00000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000050000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000000000000
00000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000050000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000070000000000007000000000000007000000000000000000000000000000000000000000000000000
00000000000000007000000000000000000000000000000070000000000007000005000000007000000000000000000000000000000000000000000000000000
00000000000000007000000000000000000000000000000000000000000000000005000000000000000000001115000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000070000000000000000000000000000001010000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000700000000000000000000000000000011c0c00000000000000000000000000070000000
000000000000000000000000000000000000000000000000000050000000000000000000000000000000000010ccc00000000000000000000000000070000000
000000000000000000000000000000000000000000000000000008888880000000000000000000000000000010c0c11100000000000000000000000000000000
00000000000000000000000000000000000000000000000000008e888888000000000000000000000000000000c0c10100000000000000000000000000000000
00000000000000000000000000000000000000050000000000008888888800000000000000000000000000000000011100000000000000000000000000000000
000000000000000000000000000000000000000000000000000008e888e000000000000000000000000000000000010000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000888e88000000000000000000000000000000000000000000000000000005000000000000000
00000000000000000000000000000000000000000000000000000088880000000000000000000000000000000050000000000000000000005000000000000000
00000000000000000000000000070000000000000000000000000008800070000000000000000000000000000050000000000000000000000000000000000000
00000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000000000
00000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009999900000000000000000
00000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000090000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000090999900000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000090900000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009995999900000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000900000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000000999900000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007000000000000000000000000000000000000050000000000000001110000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000050000000000000001010000000000000000000000000000000000050000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000011c0c00000000000000000000000000000000000000000000000070000000000
000000000000000000000000000000000000000000000000000000000700000010ccc00000000000000000000000000000000700000000000000070000000700
000000000000000000000000000000000000000000000000000000000700000010c0c11100000000000000000000000000000700000000000000000700000705
000000000000000000000000000000000000000000000000000000000000000000c0c10100000000000000000000000000000000000000000000000700000000
00000000000000000000000000000000000000000000000000000000000000000000011105000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000700000000000000010000000000000000000000000000000000000000000000700000000000
00000000000000000070000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000700000000000

__sfx__
000100001c7501c7501c7501c7501a75018750177501470014700176001660014600116000f6000e600000002020024200272002920024500275002a5002c5002d50027300263000000000000000000000000000
000100002615023150211501f1501e1501d1501c15000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002365025650286502a6502a65028650226501e6501a650186501664015640126300f6300d62000000000000000000000000000660008600096000c600106001a000000000000000000000000000000000
000500000666006660066600566005660056600466004660046400464004630046300363003630036200362003620036100361004600046000060000600006000060000600006000460002600016000000000000
001000000000000000000002500025000250002500025000250000000025000000002500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
