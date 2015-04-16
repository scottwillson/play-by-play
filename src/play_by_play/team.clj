(ns play-by-play.team
  (:require [play-by-play.player :as player]))

(defn add-players-to-team [team game]
  (assoc team :players
    (repeatedly 15 player/create)))

(defn plays-for [team game]
  (filter #(= team (:team %)) (:plays game)))

(defn points-for [team game]
  (reduce + (map :points (plays-for team game))))

(defn sum-points [team game]
  (assoc team :points (points-for (:name team) game)))

(defn update-teams [f game]
  (assoc game :teams
    (map
      (fn [team] (f team game)) (:teams game))))
