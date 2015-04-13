(ns play-by-play.season
  (:require [play-by-play.real-world :as rw]
            [incanter.stats :as stats])
  (:gen-class))

(defn games [date]
  (filter
    #(= 0 (compare (:date %) date))
    @rw/games))

(defn player-points []
  (if (< 0.5 (rand))
    (rand-int 27)
    0))

(defn player []
  (assoc
    (stats/sample @rw/players :size 1)
    :points
    (player-points)))

(defn assoc-players [team]
  (assoc team :players
    (repeatedly 15 player)))

(defn assoc-team-points [team]
  (assoc team :points
    (reduce + (map :points (:players team)))))

(defn box-score [game]
  (assoc game :teams (map assoc-team-points (map assoc-players (:teams game)))))

; (defn box-score [game]
;   (map team-box-score
;     (map assoc-players
;       (:teams game))))
;
(def season
  (map box-score @rw/games))

(defn day [& date]
  (map box-score (games (first date))))
