(ns play-by-play.real-world
  (:require [clj-time.coerce :as time-coerce]
            [clj-time.format :as time-format]
            [clojure.data.csv :as csv]
            [clojure.java.io :as io]))

(defn parse-int [str]
  (Integer/parseInt str))

(def data-file-date-format
  (time-format/formatter "EEEEE MMM d yyyy"))

(defn to-game [game-row]
  { :date          (time-coerce/to-date (time-format/parse data-file-date-format (first game-row)))
    :visitor-team  (nth game-row 2)
    :visitor-score (parse-int (nth game-row 3))
    :home-team     (nth game-row 4)
    :home-score    (parse-int (nth game-row 5))})

(def games
  (delay
    (with-open [in-file (io/reader "data/scores.csv")]
      (doall
        (map to-game
          (rest (csv/read-csv in-file)))))))

(def home-scores
  (map
    #(:home-score %) @games))

(def visitor-scores
  (map
    #(:visitor-score %) @games))

(def scores
  (concat home-scores visitor-scores))

(def teams
  (map
    #(:home-team %) @games))
