define(
  ["./react-es6","./react-es6/lib/cloneWithProps","./react-es6/lib/merge","./OverlayMixin","./domUtils","./utils","exports"],
  function(__dependency1__, __dependency2__, __dependency3__, __dependency4__, __dependency5__, __dependency6__, __exports__) {
    "use strict";
    /** @jsx React.DOM */

    var React = __dependency1__["default"];
    var cloneWithProps = __dependency2__["default"];
    var merge = __dependency3__["default"];
    var OverlayMixin = __dependency4__["default"];
    var domUtils = __dependency5__["default"];
    var utils = __dependency6__["default"];

    /**
     * Check if value one is inside or equal to the of value
     *
     * @param {string} one
     * @param {string|array} of
     * @returns {boolean}
     */
    function isOneOf(one, of) {
      if (Array.isArray(of)) {
        return of.indexOf(one) >= 0;
      }
      return one === of;
    }

    var OverlayTrigger = React.createClass({displayName: 'OverlayTrigger',
      mixins: [OverlayMixin],

      propTypes: {
        trigger: React.PropTypes.oneOfType([
          React.PropTypes.oneOf(['manual', 'click', 'hover', 'focus']),
          React.PropTypes.arrayOf(React.PropTypes.oneOf(['click', 'hover', 'focus']))
        ]),
        placement: React.PropTypes.oneOf(['top','right', 'bottom', 'left']),
        delay: React.PropTypes.number,
        delayShow: React.PropTypes.number,
        delayHide: React.PropTypes.number,
        defaultOverlayShown: React.PropTypes.bool,
        overlay: React.PropTypes.renderable.isRequired
      },

      getDefaultProps: function () {
        return {
          placement: 'right',
          trigger: ['hover', 'focus']
        };
      },

      getInitialState: function () {
        return {
          isOverlayShown: this.props.defaultOverlayShown == null ?
            false : this.props.defaultOverlayShown,
          overlayLeft: null,
          overlayTop: null
        };
      },

      show: function () {
        this.setState({
          isOverlayShown: true
        }, function() {
          this.updateOverlayPosition();
        });
      },

      hide: function () {
        this.setState({
          isOverlayShown: false
        });
      },

      toggle: function () {
        this.state.isOverlayShown ?
          this.hide() : this.show();
      },

      renderOverlay: function () {
        if (!this.state.isOverlayShown) {
          return React.DOM.span(null );
        }

        return cloneWithProps(
          this.props.overlay,
          {
            onRequestHide: this.hide,
            placement: this.props.placement,
            positionLeft: this.state.overlayLeft,
            positionTop: this.state.overlayTop
          }
        );
      },

      render: function () {
        var props = {};

        if (isOneOf('click', this.props.trigger)) {
          props.onClick = utils.createChainedFunction(this.toggle, this.props.onClick);
        }

        if (isOneOf('hover', this.props.trigger)) {
          props.onMouseOver = utils.createChainedFunction(this.handleDelayedShow, this.props.onMouseOver);
          props.onMouseOut = utils.createChainedFunction(this.handleDelayedHide, this.props.onMouseOut);
        }

        if (isOneOf('focus', this.props.trigger)) {
          props.onFocus = utils.createChainedFunction(this.handleDelayedShow, this.props.onFocus);
          props.onBlur = utils.createChainedFunction(this.handleDelayedHide, this.props.onBlur);
        }

        return cloneWithProps(
          React.Children.only(this.props.children),
          props
        );
      },

      componentWillUnmount: function() {
        clearTimeout(this._hoverDelay);
      },

      handleDelayedShow: function () {
        if (this._hoverDelay != null) {
          clearTimeout(this._hoverDelay);
          this._hoverDelay = null;
          return;
        }

        var delay = this.props.delayShow != null ?
          this.props.delayShow : this.props.delay;

        if (!delay) {
          this.show();
          return;
        }

        this._hoverDelay = setTimeout(function() {
          this._hoverDelay = null;
          this.show();
        }.bind(this), delay);
      },

      handleDelayedHide: function () {
        if (this._hoverDelay != null) {
          clearTimeout(this._hoverDelay);
          this._hoverDelay = null;
          return;
        }

        var delay = this.props.delayHide != null ?
          this.props.delayHide : this.props.delay;

        if (!delay) {
          this.hide();
          return;
        }

        this._hoverDelay = setTimeout(function() {
          this._hoverDelay = null;
          this.hide();
        }.bind(this), delay);
      },

      updateOverlayPosition: function () {
        if (!this.isMounted()) {
          return;
        }

        var pos = this.calcOverlayPosition();

        this.setState({
          overlayLeft: pos.left,
          overlayTop: pos.top
        });
      },

      calcOverlayPosition: function () {
        var childOffset = this.getPosition();

        var overlayNode = this.getOverlayDOMNode();
        var overlayHeight = overlayNode.offsetHeight;
        var overlayWidth = overlayNode.offsetWidth;

        switch (this.props.placement) {
          case 'right':
            return {
              top: childOffset.top + childOffset.height / 2 - overlayHeight / 2,
              left: childOffset.left + childOffset.width
            };
          case 'left':
            return {
              top: childOffset.top + childOffset.height / 2 - overlayHeight / 2,
              left: childOffset.left - overlayWidth
            };
          case 'top':
            return {
              top: childOffset.top - overlayHeight,
              left: childOffset.left + childOffset.width / 2 - overlayWidth / 2
            };
          case 'bottom':
            return {
              top: childOffset.top + childOffset.height,
              left: childOffset.left + childOffset.width / 2 - overlayWidth / 2
            };
          default:
            throw new Error('calcOverlayPosition(): No such placement of "' + this.props.placement + '" found.');
        }
      },

      getPosition: function () {
        var node = this.getDOMNode();
        var container = this.getContainerDOMNode();

        var offset = container.tagName == 'BODY' ?
          domUtils.getOffset(node) : domUtils.getPosition(node, container);

        return merge(offset, {
          height: node.offsetHeight,
          width: node.offsetWidth
        });
      }
    });

    __exports__["default"] = OverlayTrigger;
  });