/* eslint-disable require-jsdoc */

class LocationOptionAttachedInputsComponent {
  constructor(options = {}) {
    this.wrapperField = options.wrapperField;
    this.controllerFieldSelector = options.controllerFieldSelector;
    this.dependentInputSelector = options.dependentInputSelector;
    this.controllerSelector = this.wrapperField.find(this.controllerFieldSelector);
    this._bindEvent();
    this._run();
  }

  _run() {
    this.controllerSelector.each((idx, el) => {
      const $field = $(el);
      const enabled = $field.is(":checked");
      $field.parents("div.collection-input").find(this.dependentInputSelector).each((idx, element) => {
        $(element).prop("disabled", !enabled)
      });
    });
  }

  _bindEvent() {
    this.controllerSelector.each((idx, el) => {
      const $field = $(el)
      $field.on("change", () => {
        this._run();
      });
    })
  }
}

export default function createLocationOptionAttachedInputs(options) {
  return new LocationOptionAttachedInputsComponent(options);
}
