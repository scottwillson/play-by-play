(ns play-by-play.game
  (:require [play-by-play.real-world :as rw]
            [incanter.stats :as stats]))

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

(defn plays [game]
  [{:name "fgm"}])

(defn play [game]
  (assoc
    (assoc game :teams
      (map assoc-player-points
        (:teams game)))
        :plays (plays game)))

(defn box-score [game]
  (play
    (assoc game :teams
      (map assoc-players (:teams game)))))
