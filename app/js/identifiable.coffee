#   Fast UUID generator, RFC4122 version 4 compliant.
#   @author Jeff Ward (jcward.com).
#   @license MIT license
#   @link http://stackoverflow.com/questions/105034/how-to-create-a-guid-uuid-in-javascript/21963136#21963136
#   ported to coffeescript by Eric Dobbs
lut = new Array(256)
lut[i] = '0'+i.toString(16) for i in _.range(0,16)
lut[i] = i.toString(16) for i in _.range(17,256)
  
UUID = ->
  d0 = Math.random()*0xffffffff|0
  d1 = Math.random()*0xffffffff|0
  d2 = Math.random()*0xffffffff|0
  d3 = Math.random()*0xffffffff|0
  lut[d0&0xff]+lut[d0>>8&0xff]+lut[d0>>16&0xff]+lut[d0>>24&0xff]+'-'+
  lut[d1&0xff]+lut[d1>>8&0xff]+'-'+lut[d1>>16&0x0f|0x40]+lut[d1>>24&0xff]+'-'+
  lut[d2&0x3f|0x80]+lut[d2>>8&0xff]+'-'+lut[d2>>16&0xff]+lut[d2>>24&0xff]+
  lut[d3&0xff]+lut[d3>>8&0xff]+lut[d3>>16&0xff]+lut[d3>>24&0xff]

@identifiable = (that) ->
  if that.uuid?
    return that
  uuid = UUID();
  that.uuid = -> uuid
  that
