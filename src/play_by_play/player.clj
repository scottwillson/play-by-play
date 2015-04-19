(ns play-by-play.player
  (:require [play-by-play.real-world :as rw]
            [incanter.stats :as stats]))

(defn create []
  (stats/sample @rw/players :size 1))

(defn plays-for [player game]
  (filter #(= player (:player %)) (:plays game)))

(defn points-for [player game]
  (reduce + (map :points (plays-for player game))))

(defn sum-points
  "Sum and associate points for each player"
  [player game]
  (assoc player :points (points-for (:name player) game)))

(defn update-players
  "Update (map + assoc) players on each team in game using f"
  [f game]
  (assoc game :teams
    (map (fn [team]
      (assoc team :players
        (map
          (fn [player]
            (f player game))
          (:players team))))
      (:teams game))))
