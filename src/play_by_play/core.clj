(ns play-by-play.core
  (:require [play-by-play.real-world :as rw]
            [play-by-play.season :refer :all]
            [incanter.stats :as stats]
            [clojure.tools.cli :refer [parse-opts]]
            [clojure.string :as str :refer [trim]])
  (:gen-class))

(defn real-world-stats
  []
  (do
    (println
      "minimum"
      (apply min rw/scores))
    (println
      "maximum"
      (apply max rw/scores))
    (println
      "mean"
      (stats/mean rw/scores))))

(defn print-season
  []
  (println "season"))

(defn day
  []
  (println "day"))

(defn -main
  [& args]
  (let [{:keys [options arguments errors summary]} (parse-opts args [])]
    (case (first arguments)
      "season" (print-season)
      "day"    (day)
               (real-world-stats))))
