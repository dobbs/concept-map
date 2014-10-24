describe "Link", ->
  describe "linear", ->
    When ->
      @source = new Node("source")
      @target = new Node("target")
      @link = new Link(@source, @target, "annotation")

    describe "constructor", ->
      Then -> expect(@link.source).toEqual @source
      Then -> expect(@link.target).toEqual @target
      Then -> expect(@link.annotation).toEqual "annotation"

    describe "isCircular", ->
      Then -> expect(@link.isCircular()).toBeFalsy()
          
    describe "midpoint", ->
      When ->
        [@source.x, @source.y] = [10, 10]
        [@target.x, @target.y] = [20, 30]
      Then -> expect(@link.midpoint()).toEqual {x: 15, y: 20}

  describe "circular", ->
    When ->
      @source = new Node("highlander")
      @link = new Link(@source, @source, "annotation")

    Then -> expect(@link.isCircular()).toBeTruthy()
      
    