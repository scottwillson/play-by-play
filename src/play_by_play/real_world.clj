(ns play-by-play.real-world
  (:require [cheshire.core :as cheshire]
            [clj-time.coerce :as time-coerce]
            [clj-time.format :as time-format]
            [incanter.stats :as stats]
            [clojure.data.csv :as csv]
            [clojure.java.io :as io]))

(defn parse-int [str]
  (Integer/parseInt str))

(def data-file-date-format
  (time-format/formatter "EEEEE MMM d yyyy"))

(defn to-game [game-row]
  { :date (time-coerce/to-date (time-format/parse data-file-date-format (first game-row)))
    :teams [
      {
        :name  (nth game-row 2)
        :location "visitor"
        :points (parse-int (nth game-row 3))}
      {
        :name  (nth game-row 4)
        :location "home"
        :points (parse-int (nth game-row 5))}]})

(def games
  (delay
    (with-open [in-file (io/reader "data/scores.csv")]
      (doall
        (map to-game
          (rest (csv/read-csv in-file)))))))


(defn to-player [player-row]
  { :name (first player-row)})

(def players
  (delay
    (with-open [in-file (io/reader "data/players.csv")]
      (doall
        (map to-player
          (rest (csv/read-csv in-file)))))))

(def home-scores
  (map
    #(:points (last (:teams %))) @games))

(def visitor-scores
  (map
    #(:points (first (:teams %))) @games))

(def scores
  (concat home-scores visitor-scores))

(def teams
  (map
    #(first (:teams %)) @games))

(defn game-files []
  (filter #(.isFile %)
    (file-seq (io/file "data/games"))))

(def headers-file
  (delay
    (cheshire/parse-string (slurp (first (game-files))))))

(defn headers []
  (((@headers-file
    "resultSets") 0) "headers"))

(defn file-rows [f]
  ((((cheshire/parse-string (slurp f))
    "resultSets") 0) "rowSet"))

(defn file-plays [f]
  (map (fn[row] (zipmap (headers) row)) (file-rows f)))

(defn plays []
  (flatten (map file-plays (game-files))))

(defn home-and-visitor-descriptions
  [file-row]
  (clojure.string/join ""
    [(file-row "HOMEDESCRIPTION")
     (file-row "VISITORDESCRIPTION")]))

(defn fgm []
  (filter #(and
      (= 1 (% "EVENTMSGTYPE"))
      (not (.contains (home-and-visitor-descriptions %) "3PT")))
    (plays)))

(defn three-pm []
  (filter #(and
      (= 1 (% "EVENTMSGTYPE"))
      (.contains (home-and-visitor-descriptions %) "3PT"))
    (plays)))

(defn ftm []
  (filter #(and
      (= 3 (% "EVENTMSGTYPE"))
      (not (.contains (home-and-visitor-descriptions %) "MISS")))
    (plays)))
