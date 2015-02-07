(ns play-by-play.real-world)

(require '[clojure.data.csv :as csv]
         '[clojure.java.io :as io])

(def scores
  (with-open [in-file (io/reader "data/scores.csv")]
    (doall
      (csv/read-csv in-file))))
