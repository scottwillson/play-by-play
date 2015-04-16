(ns play-by-play.season
  (:require [play-by-play.game :as game :refer [box-score]]
            [play-by-play.real-world :as rw]
            [incanter.stats :as stats])
  (:gen-class))

(defn games [date]
  (filter
    #(= 0 (compare (:date %) date))
    @rw/games))

(def season
  (map game/box-score @rw/games))

(defn day [& date]
  (map game/box-score (games (first date))))
