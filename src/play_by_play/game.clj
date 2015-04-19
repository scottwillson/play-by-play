(ns play-by-play.game
  (:require [play-by-play.player :as player :refer [update-players]]
            [play-by-play.team :as team :refer [add-players-to-team update-teams]]
            [incanter.stats :as stats]))

; TODO sample a weighted list of [player, team] weighted by FGM per minute
(defn create-play [game]
  (let [team   (stats/sample (:teams game) :size 1)
        player (stats/sample (:players team) :size 1)]
  {:name "FGM"
   :player (:name player)
   :points 2
   :team (:name team)}))

(defn create-plays [game]
  (repeatedly 97 #(create-play game)))

(defn add-players [game]
  (update-teams add-players-to-team game))

(defn add-plays [game]
  (assoc game :plays (create-plays game)))

(defn sum-player-points [game]
  (update-players player/sum-points game))

(defn sum-team-points [game]
  (update-teams team/sum-points game))

(defn sum-points [game]
  (-> game
    (sum-player-points)
    (sum-team-points)))

(defn box-score
  "'Play' the game"
  [game]
  (-> game
    (add-players)
    (add-plays)
    (sum-points)))
