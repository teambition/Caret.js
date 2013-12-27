define (require, exports, module) ->

  class EditableCaret
    constructor: (inputor) ->
      @domInputor = inputor

    # NOTE: Duck type
    setPos: (pos) -> @domInputor
    getIEPosition: -> $.noop()
    getPosition: -> $.noop()

    getOldIEPos: ->
      textRange = document.selection.createRange()
      preCaretTextRange = document.body.createTextRange()
      preCaretTextRange.moveToElementText(@domInputor)
      preCaretTextRange.setEndPoint("EndToEnd", textRange)
      preCaretTextRange.text.length

    getPos: ->
      if range = this.range() # Major Browser and IE > 10
        clonedRange = range.cloneRange()
        clonedRange.selectNodeContents(@domInputor)
        clonedRange.setEnd(range.endContainer, range.endOffset)
        pos = clonedRange.toString().length
        clonedRange.detach()
        pos
      else if document.selection #IE < 9
        this.getOldIEPos()

    getOldIEOffset: ->
      range = document.selection.createRange().duplicate()
      range.moveStart "character", -1
      rect = range.getBoundingClientRect()
      { height: rect.bottom - rect.top, left: rect.left, top: rect.top }

    getOffset: (pos) ->
      if window.getSelection and range = this.range()
        return null if range.endOffset - 1 < 0
        clonedRange = range.cloneRange()
        # NOTE: have to select a char to get the rect.
        clonedRange.setStart(range.endContainer, range.endOffset - 1)
        clonedRange.setEnd(range.endContainer, range.endOffset)
        rect = clonedRange.getBoundingClientRect()
        offset = { height: rect.height, left: rect.left + rect.width, top: rect.top }
        clonedRange.detach()
      else if document.selection # ie < 9
        offset = this.getOldIEOffset()

      if offset
        offset.top += $(window).scrollTop()
        offset.left += $(window).scrollLeft()

      offset

    range: ->
      return unless window.getSelection
      sel = window.getSelection()
      if sel.rangeCount > 0 then sel.getRangeAt(0) else null	

	ICaret ||= {}
	ICaret.EditableCart = EditableCart
