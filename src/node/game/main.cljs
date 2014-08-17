(ns game.main
  (:require [cljs.nodejs :as node]
            [game.core :refer [game-states pay! gain! draw!] :as core]))

(aset js/exports "main" game.main)
(enable-console-print!)
(defn noop [])
(set! *main-cli-fn* noop)

(def commands
  {"say" core/say!
   "mulligan" core/mulligan!
   "keep" core/keep!
   "draw" (fn [state side args]
            (when (pay! state side :click 1) (draw! state side)))
   "credit" (fn [state side args]
              (when (pay! state side :click 1) (gain! state side :credit)))
   "purge" (fn [state side args]
             (when (pay! state side :click 3) (core/purge! state side)))
   "remove-tag" (fn [state side args]
                  (pay! state side :click 1 :credit 2 :tag 1))})

(defn exec [action args]
  (let [params (js->clj args :keywordize-keys true)
        gameid (:gameid params)
        state (@game-states (:gameid params))]
    (case action
      "init" (core/init-game params)
      "do" ((commands (:command params)) state (keyword (:side params)) (:args params)))
    (clj->js @(@game-states gameid))))