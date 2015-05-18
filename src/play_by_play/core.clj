(ns play-by-play.core
  (:require [play-by-play.app-server.date-conversion :as dates]
            [play-by-play.game :as game]
            [play-by-play.real-world :as rw]
            [play-by-play.season :refer :all]
            [incanter.stats :as stats]
            [clojure.tools.cli :refer [parse-opts]]
            [clojure.string :as str :refer [trim]])
  (:gen-class))

(defn real-world-stats
  []
  (do
    (println
      "count FGM: "
      (count (rw/fgm)))
    (println
      "count 3PM: "
      (count (rw/three-pm)))
    (println
      "count FTM: "
      (count (rw/ftm)))
    (println
      "minimum game points: "
      (apply min rw/scores))
    (println
      "maximum game points: "
      (apply max rw/scores))
    (println
      "mean game points: "
      (stats/mean rw/scores))))

(defn print-season
  []
  (println season))

(defn print-day
  [date]
  ; TODO Move date functions
  (println (day (dates/parse-string date))))

(defn print-box-score
  []
  (println (game/box-score (first @rw/games))))

(defn -main
  [& args]
  (let [{:keys [options arguments errors summary]} (parse-opts args [])]
    (case (first arguments)
      "season"    (print-season)
      "day"       (print-day (second arguments))
      "box-score" (print-box-score)
                  (real-world-stats))))
