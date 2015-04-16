(ns play-by-play.season
  (:require [play-by-play.real-world :as rw]
            [incanter.stats :as stats])
  (:gen-class))

(defn games [date]
  (filter
    #(= 0 (compare (:date %) date))
    @rw/games))

(defn player []
  (stats/sample @rw/players :size 1))

(defn assoc-players [team]
  (assoc team :players
    (repeatedly 15 player)))

; TODO add up points in #play
(defn assoc-team-points [team]
  (assoc team :points
    (reduce + (map :points (:players team)))))

(defn assoc-player-points [team]
  (assoc team :players
    (map #(assoc % :points (rand-int 15))
      (:players team))))

(defn play [game]
  (assoc game :teams
    (map assoc-player-points
      (:teams game))))

(defn box-score [game]
  (play
    (assoc game :teams
      (map assoc-players (:teams game)))))

(def season
  (map box-score @rw/games))

(defn day [& date]
  (map box-score (games (first date))))
