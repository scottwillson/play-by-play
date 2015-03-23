(ns play-by-play.homepage-test
  (:import [java.lang ProcessBuilder])
  (:require [clojure.test :refer :all]
            [clj-webdriver.taxi :refer :all]
            [ring.adapter.jetty :as jetty :only [run-jetty]]
            [play-by-play.app-server.handler :as handler :only [app]]))

(deftest ^:browser home-page
  (testing "view"
    (to "http://0.0.0.0:3000?date=2014-10-28")
    (is (and
      (exists? ".container")
      (= "New Orleans" (text ".home .team-name"))))))

(defn ^:browser start-app-server [f]
  (loop [server (jetty/run-jetty 'handler/app {:port 3000, :join? false})]
    (if (.isStarted server)
      (do
        (f)
        (.stop server))
      (recur server))))

(defn start-web-server [f]
  (do
    (let [process (-> (ProcessBuilder. ["node" "node/app.js"])
                      (.start))]
      (f)
      (-> process (.destroy)))))

(defn ^:browser start-browser-fixture
  [f]
  (set-driver! {:browser :phantomjs})
  (f))

(defn ^:browser quit-browser-fixture
  [f]
  (f)
  (quit))

(use-fixtures :once start-app-server start-web-server)
(use-fixtures :each start-browser-fixture quit-browser-fixture)

