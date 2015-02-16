(ns play-by-play.real-world)

(require '[clojure.data.csv :as csv]
         '[clojure.java.io :as io])

(def games
  (delay
    (with-open [in-file (io/reader "data/scores.csv")]
      (doall
        (csv/read-csv in-file)))))


(defn parse-int [str]
  (Integer/parseInt str))

(def home-scores
  (map
    #(parse-int (nth % 5)) (rest @games)))

(def visitor-scores
  (map
    #(parse-int (nth % 3)) (rest @games)))

(def scores
  (concat home-scores visitor-scores))