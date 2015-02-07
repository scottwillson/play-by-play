(ns play-by-play.core
  (:require [play-by-play.real-world :as rw])
  (:gen-class))

(defn -main
  [& args]
  (apply println rw/scores))

(def score
  [0, 0])
