(ns play-by-play.team
  (:require [play-by-play.player :as player]))

(defn add-players-to-team [team game]
  (assoc team :players
    (distinct
      (repeatedly 15 player/create))))

(defn plays-for [team game]
  (filter #(= team (:team %)) (:plays game)))

(defn points-for [team game]
  (reduce + (map :points (plays-for team game))))

(defn sum-points
  "Sum and associate points for each team"
  [team game]
  (assoc team :points (points-for (:name team) game)))

(defn update-teams
  "Update (map + assoc) each team in game using f"
  [f game]
  (assoc game :teams
    (map
      (fn [team] (f team game)) (:teams game))))
