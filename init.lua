minetest_mod_astral_body = {}
minetest.register_entity("minetest_mod_astral_body:astral_body",
{
  obj, -- ObjectRef from minetest.add_entity()
  player, -- ObjectRef player
  speed_multiplier = 10,
  velocity = vector.new(),
  description = "Player's astral body.",
  on_step = function(self,seconds_since_last_step)
    if self.obj == nil then 
      self.object:remove() 
    else
      local speed = self.player.obj:get_physics_override().speed * self.speed_multiplier
      local controls = self.player.obj:get_player_control()
      local direction = self.player.obj:get_look_dir()

      if controls.up and not controls.down then
        self.velocity = vector.add(self.velocity,vector.multiply(direction,speed))
      end
      if controls.down and not controls.up then
        self.velocity = vector.add(self.velocity,vector.multiply(direction,-speed))
      end
      if controls.jump and not controls.sneak then
        self.velocity = vector.add(self.velocity,vector.multiply(
          minetest_mod_astral_body.calculate_direction_by_yaw_and_pitch(0,-(90*(math.pi/180))),
          speed
        ))
      end
      if controls.sneak and not controls.jump then
        self.velocity = vector.add(self.velocity,vector.multiply(
          minetest_mod_astral_body.calculate_direction_by_yaw_and_pitch(0,(90*(math.pi/180))),
          speed
        ))
      end
      if controls.right and not controls.left then
        self.velocity = vector.add(self.velocity,vector.multiply(
          minetest_mod_astral_body.calculate_direction_by_yaw_and_pitch(self.player.obj:get_look_horizontal()-(90*(math.pi/180)),0),
          speed
        ))
      elseif controls.left and not controls.right then
        self.velocity = vector.add(self.velocity,vector.multiply(
          minetest_mod_astral_body.calculate_direction_by_yaw_and_pitch(self.player.obj:get_look_horizontal()+(90*(math.pi/180)),0),
          speed
        ))
      end
      if not (controls.up or controls.down or controls.right or controls.left or controls.jump or controls.sneak) then
        self.velocity = vector.multiply(vector.normalize(self.velocity),0)
      else
        self.velocity = vector.multiply(vector.normalize(self.velocity),speed)
      end
      self.obj:set_velocity(self.velocity)
    end
  end
})
minetest_mod_astral_body.ascend_player_into_astral_body = function(arguments)
  local astral_body = minetest.add_entity(arguments.position,"minetest_mod_astral_body:astral_body"):get_luaentity()
  astral_body.obj = astral_body.object
  astral_body.player = { obj = arguments.player_obj }
  astral_body.player.obj:set_attach(astral_body.obj,"",{x=0,y=0,z=0},{x=0,y=0,z=0})
  return astral_body
end
minetest_mod_astral_body.calculate_direction_by_yaw_and_pitch = function(yaw,pitch)
  return { x = -(math.cos(pitch) * math.sin(yaw)), y = -(math.sin(pitch)), z = math.cos(pitch) * math.cos(yaw) }
end
-- minetest.register_node("minetest_mod_astral_body:astral_block",
-- {
--   description = "Uncomment this block to test the mod.",
--   tiles = {"^[colorize:#FFF"},
--   on_rightclick = function(node_pos, node_obj, player_obj, player_item)
--     minetest_mod_astral_body.ascend_player_into_astral_body(
--     {
--       position = {x=node_pos.x,y=node_pos.y-1.5,z=node_pos.z}, -- y=-1.5 to put view inside the block
--       player_obj = player_obj,
--     })
--   end
-- })