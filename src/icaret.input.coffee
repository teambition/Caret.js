define (require, exports, module) ->

  class InputCaret
    constructor: (@inputor, @root) ->
      @document = @root.document

    getIEPos: ->
      # https://github.com/ichord/Caret.js/wiki/Get-pos-of-caret-in-IE
      inputor = @inputor
      range = @document.selection.createRange()
      pos = 0
      # selection should in the inputor.
      if range and range.parentElement() is inputor
        normalizedValue = inputor.value.replace /\r\n/g, "\n"
        len = normalizedValue.length
        textInputRange = inputor.createTextRange()
        textInputRange.moveToBookmark range.getBookmark()
        endRange = inputor.createTextRange()
        endRange.collapse false
        if textInputRange.compareEndPoints("StartToEnd", endRange) > -1
          pos = len
        else
          pos = -textInputRange.moveStart "character", -len
      pos

    getPos: ->
      if @document.selection then this.getIEPos() else @inputor.selectionStart

    setPos: (pos) ->
      inputor = @inputor
      if @document.selection #IE
        range = inputor.createTextRange()
        range.move "character", pos
        range.select()
      else if inputor.setSelectionRange
        inputor.setSelectionRange pos, pos
      inputor

    getIEOffset: (pos) ->
      textRange = @inputor.createTextRange()
      pos ||= this.getPos()
      textRange.move('character', pos)

      x = textRange.boundingLeft
      y = textRange.boundingTop
      h = textRange.boundingHeight

      {left: x, top: y, height: h}

    getOffset: (pos) ->
      $inputor = @$inputor
      if @document.selection
        offset = this.getIEOffset(pos)
        offset.top += $(window).scrollTop() + $inputor.scrollTop()
        offset.left += $(window).scrollLeft() + $inputor.scrollLeft()
        offset
      else
        offset = $inputor.offset()
        position = this.getPosition(pos)
        offset =
          left: offset.left + position.left - $inputor.scrollLeft()
          top: offset.top + position.top - $inputor.scrollTop()
          height: position.height

    getPosition: (pos)->
      $inputor = @$inputor
      format = (value) ->
        value.replace(/</g, '&lt')
        .replace(/>/g, '&gt')
        .replace(/`/g,'&#96')
        .replace(/"/g,'&quot')
        .replace(/\r\n|\r|\n/g,"<br />")

      pos = this.getPos() if pos is undefined
      start_range = $inputor.val().slice(0, pos)
      html = "<span>"+format(start_range)+"</span>"
      html += "<span id='caret'>|</span>"

      new CaretFinder($inputor).findIn(html)

    getIEPosition: (pos) ->
      offset = this.getIEOffset pos
      inputorOffset = @$inputor.offset()
      x = offset.left - inputorOffset.left
      y = offset.top - inputorOffset.top
      h = offset.height

      {left: x, top: y, height: h}

  # @example
  #   mirror = new Mirror($("textarea#inputor"))
  #   html = "<p>We will get the rect of <span>@</span>icho</p>"
  #   mirror.create(html).rect()
  class CaretSeeker
    css_attr: [
      "overflowY", "height", "width", "paddingTop", "paddingLeft",
      "paddingRight", "paddingBottom", "marginTop", "marginLeft",
      "marginRight", "marginBottom","fontFamily", "borderStyle",
      "borderWidth","wordWrap", "fontSize", "lineHeight", "overflowX",
      "text-align",
    ]

    constructor: (@inputor) ->

    mirrorCss: ->
      css =
        position: 'absolute'
        left: -9999
        top:0
        zIndex: -20000
        'white-space': 'pre-wrap'
      $.each @css_attr, (i,p) =>
        css[p] = @$inputor.css p
      css

    findIn: (html) ->
      @$mirror = $('<div></div>')
      @$mirror.css this.mirrorCss()
      @$mirror.html(html)
      @$inputor.after(@$mirror)
      this.rect()

    # 获得标记的位置
    #
    # @return [Object] 标记的坐标
    #   {left: 0, top: 0, bottom: 0}
    rect: ->
      $flag = @$mirror.find "#caret"
      pos = $flag.position()
      rect = {left: pos.left, top: pos.top, height: $flag.height() }
      @$mirror.remove()
      rect

  ICaret ||= {}
  ICaret.utils = utils
  ICaret.InputMirror = Mirror
  ICaret.InputCaret = InputCaret
