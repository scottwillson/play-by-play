(ns play-by-play.app-server.date-conversion
  (:require [clj-time.coerce :as time-coerce]
            [clj-time.format :as time-format]))

(def date-format (time-format/formatters :date))

(defn parse-string [date]
  ; TODO default to today
  (if-not (nil? date)
    (time-coerce/to-date
      (time-format/parse date-format date))))
