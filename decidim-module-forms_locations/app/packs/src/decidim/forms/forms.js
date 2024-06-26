/* eslint-disable require-jsdoc */

import createOptionAttachedInputs from "src/decidim/forms/option_attached_inputs.component"
import createLocationOptionAttachedInputs from "src/decidim/forms/location_option_attached_inputs.component"
import createAutosortableCheckboxes from "src/decidim/forms/autosortable_checkboxes.component"
import createDisplayConditions from "src/decidim/forms/display_conditions.component"
import createMaxChoicesAlertComponent from "src/decidim/forms/max_choices_alert.component"

$(() => {
  $(".radio-button-collection, .check-box-collection").each((idx, el) => {
    createOptionAttachedInputs({
      wrapperField: $(el),
      controllerFieldSelector: "input[type=radio], input[type=checkbox]",
      dependentInputSelector: "input[type=text], input[type=hidden]"
    });
  });

  $(".answer-options-collection").each((idx, el) => {
    createLocationOptionAttachedInputs({
      wrapperField: $(el),
      controllerFieldSelector: "input[type=checkbox]",
      dependentInputSelector: "input[type=hidden]"
    })
  })

  $.unique($(".check-box-collection").parents(".answer")).each((idx, el) => {
    const maxChoices = $(el).data("max-choices");
    if (maxChoices) {
      createMaxChoicesAlertComponent({
        wrapperField: $(el),
        controllerFieldSelector: "input[type=checkbox]",
        controllerCollectionSelector: ".check-box-collection",
        alertElement: $(el).find(".max-choices-alert"),
        maxChoices: maxChoices
      });
    }
  });

  $(".sortable-check-box-collection").each((idx, el) => {
    createAutosortableCheckboxes({
      wrapperField: $(el)
    })
  });

  $(".answer-questionnaire .question[data-conditioned='true']").each((idx, el) => {
    createDisplayConditions({
      wrapperField: $(el)
    });
  });

  const $form = $("form.answer-questionnaire");
  if ($form.length > 0) {
    $form.find("input, textarea, select").on("change", () => {
      $form.data("changed", true);
    });

    const safePath = $form.data("safe-path").split("?")[0];
    $(document).on("click", "a", (event) => {
      window.exitUrl = event.currentTarget.href;
    });
    $(document).on("submit", "form", (event) => {
      window.exitUrl = event.currentTarget.action;
    });

    window.addEventListener("beforeunload", (event) => {
      const exitUrl = window.exitUrl;
      const hasChanged = $form.data("changed");
      window.exitUrl = null;

      if (!hasChanged || (exitUrl && exitUrl.includes(safePath))) {
        return;
      }

      event.returnValue = true;
    });
  }

  const callback = (mutationsList) => {
    mutationsList.forEach((mutation) => {
      if (mutation.type === "attributes") {
        const classList = Array.from(mutation.target.classList);
        if (!classList.includes("hide")) {
          mutation.target.querySelectorAll("[data-decidim-map]").forEach((map) => {
            const mapData = JSON.parse(map.getAttribute("data-decidim-map"));

            const mapCtrl = $(map).data("map-controller");
            mapCtrl.map.invalidateSize();

            if (mapData.type === "locations") {
              mapCtrl.start();
              mapCtrl.refreshMarkers();
            }
          })
        }
      }
    })
  };

  const observer = new MutationObserver(callback)

  const config = { attributes: true }

  if ($(".questionnaire-step")) {
    $(".questionnaire-step").each((idx, el) => {
      observer.observe(el, config);
    })
  }
})
