(ns surprisebuild.surprisebuildweb2.core
  (:require
   [reagent.core :as r]
   [reagent.dom :as d]
   [uix.core :as uix :refer [defui $]]
   [uix.dom]
   [uix.re-frame :as urf]
   [surprisebuild.surprisebuildweb2.hooks :as hooks]
   [surprisebuild.surprisebuildweb2.subs]
   [surprisebuild.surprisebuildweb2.handlers]
   [surprisebuild.surprisebuildweb2.fx]
   [surprisebuild.surprisebuildweb2.db]
   [surprisebuild.surprisebuildweb2.config :as config]
   [re-frame.core :as rf]
   [clojure.string :as str]
   [goog.string :as gs]
   [goog.string.format]
   [goog.object :as gobj]
   [react-oidc-context :as oidc :refer [AuthProvider useAuth]]
   [react :refer [StrictMode]]))

(defn on-sign-in-callback []
  (set! (.. js/window -location -href) "/"))

(def client-id "1f7ud36u0tud5lt9pf7mb6cmoq")
(def redirect_uri (if config/debug? "http://localhost:8080/" "https://www.surprisebuild.com/"))
(def cdn-domain-name "https://d32bykpr179a34.cloudfront.net")

(def cognito-auth-config
  #js {"authority" "https://cognito-idp.us-east-1.amazonaws.com/us-east-1_R56ssR1OX"
       "client_id" client-id
       "redirect_uri" redirect_uri
       "response_type" "code"
       "scope" "openid email"
       "onSigninCallback" on-sign-in-callback});

;; -------------------------
;; Views

(defn comparison-form []
  (let [[partA partB] (urf/use-subscribe [:app/comparison-parts])]
    ($ :div
       ($ :table
          ($ :tbody
             ($ :tr
                ($ :td ($ :img {:src (str cdn-domain-name "/" partA ".png")}))
                ($ :td ($ :img {:src (str cdn-domain-name "/" partB ".png")})))))
       ($ :p "Do these two parts connect?")
       ($ :button {:on-click #(rf/dispatch [:app/shuffle-comparison-parts])} "yes")
       ($ :button {:on-click #(rf/dispatch [:app/shuffle-comparison-parts])} "no"))))

(defui sign-in-form [{:keys [auth]}]
  ($ :div
     ($ :h2 "Login")
     ($ :button {:on-click (fn [] (.signinRedirect ^js auth))} "Log in")))

(defui sign-out-form [{:keys [auth]}]
  ($ :div
     ($ :button {:on-click (fn [] (.removeUser ^js auth))} "Logout")))

(defui profile-view [{:keys [auth]}]
  (let [user (.-user auth)
        profile (.-profile user)]
    ($ :div
       ($ :p (str "Logged in as: " (.-email profile)))
       ($ sign-out-form {:auth auth}))))

(defui body []
  ($ :div
     ($ comparison-form)
     ($ profile-view {:auth (useAuth)})))

(defui header []
  ($ :header.app-header
     ($ :div {:width 32}
        ($ :p {:style {:font-family "Montserrat" :font-size 48}} "surprisebuild"))))

(defui footer []
  ($ :footer.app-footer
     ($ :small "made by Daniel Craig")))

(defui authenticated-app []
  (let [auth (useAuth)]
    ($ :div
       (cond
         (.-isAuthenticated auth) ($ body)
         (.-isLoading auth) "Loading..."
         (.-error auth) (str "Error: " (gobj/get auth "error"))
         :else ($ sign-in-form {:auth auth})))))

(defui app []
  (let [todos (hooks/use-subscribe [:app/todos])]
    ($ StrictMode
       ($ AuthProvider
          cognito-auth-config
          ($ :.app
             ($ header)
             ($ authenticated-app)
             ($ footer))))))

;; -------------------------
;; Initialize app

(defonce root
  (uix.dom/create-root (js/document.getElementById "app")))

(defn render []
  (rf/dispatch-sync [:app/init-db surprisebuild.surprisebuildweb2.db/default-db])
  (uix.dom/render-root ($ app) root))

(defn ^:export init! []
  (render))
