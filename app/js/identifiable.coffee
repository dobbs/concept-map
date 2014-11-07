id = 0
class Identifiable
  constructor: -> @unique_identifier = ++id
  

@Identifiable = Identifiable