(ns conquest.help
  (:require [om.core :as om :include-macros true]
            [sablono.core :as sab :include-macros true]
            [clojure.string :refer [split]]))

(def app-state (atom {}))

(def help-data
  "List of maps with FAQ about jinteki.net. Every section MUST have an :id here, so the links can work."
  (list
    {:id "general"
     :title "General"
     :sub (list
            {:id "dostuff"
             :title "How do I do I perform actions in a game?"
             :content (list
                        [:p "In general, if you want to perform an action connected to a card, try clicking that card. "
                         "Either something will happen or a menu should appear."])}
            )}))

(def help-toc
  "Generates list serving as help's table of contents. Parses help-data."
  [:nav {:role "navigation" :class "table-of-contents"}
    [:ul (for [{:keys [id title sub] :as section} help-data]
      [:li [:a (when id {:href (str "#" id)}) title]
       [:ul (for [{:keys [id title] :as question} sub]
              [:li [:a (when id {:href (str "#" id)}) title]])]])]])

(def help-contents
  "Takes help-data and translates it to HTML tags."
  (for [{:keys [id title sub] :as section} help-data]
    (list [:h2 {:id id} title]
          (for [{:keys [id title content] :as question} sub]
            (list [:h3 {:id id} title]
                  content)))))

(defn help [cursor owner]
  (om/component
    (sab/html
      [:div.help.panel.blue-shade
       [:h2 "Help Topics"]
       help-toc
       help-contents])))

(om/root help app-state {:target (. js/document (getElementById "help"))})
