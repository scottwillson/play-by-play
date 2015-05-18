(ns play-by-play.game
  (:require [play-by-play.player :as player :refer [update-players]]
            [play-by-play.team :as team :refer [add-players-to-team update-teams]]
            [incanter.stats :as stats]))

; Percentages from one random game
(defn- made-basket []
  (let [r (rand)]
  (cond
    (< r 0.62) {:name "FGM" :points 2}
    (< r 0.76) {:name "3PM" :points 3}
    :else      {:name "FTM" :points 1})))

; TODO sample a weighted list of [player, team] weighted by FGM per minute
; 36 11 21
; 42 6 9
; 78 17 30 = 125
(defn create-play [game]
  (let [team   (stats/sample (:teams game) :size 1)
        player (stats/sample (:players team) :size 1)
        basket (made-basket)]
  (assoc basket
    :player (:name player)
    :team (:name team))))

(defn create-plays [game]
  (repeatedly 102 #(create-play game)))

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
