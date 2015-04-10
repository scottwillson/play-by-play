(ns play-by-play.season
  (:require [play-by-play.real-world :as rw]
            [incanter.stats :as stats])
  (:gen-class))

(defn random-score []
  (stats/sample rw/scores :size 1))

(defn score [game]
  (assoc game
    :home-score (random-score)
    :visitor-score (random-score)))

(defn games [date]
  (filter
    #(= 0 (compare (:date %) date))
    @rw/games))

(defn game-scores [date]
  (map score (games date)))

(defn day [& date]
  (game-scores (first date)))

(def season
  (map score @rw/games))
