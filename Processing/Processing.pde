/*
 * Télésurveillance vidéo à distance
 * 
 * Outils pour la récupération, le traitement et l'export
 * d'images dans le projet final d'Informatique et Sciences
 * du Numérique.
 * 
 * Auteur : Felix SEMPE-BOURDON
 *
 * Date de création : 2015-02-14
 * Date de modification : 2015-05-17
 * 
 * Licence CC-BY-NC-SA
 */


// importation des librairies
import processing.video.*;
import java.util.Date;
import java.text.SimpleDateFormat;
import gifAnimation.*;

// définition des variables
double timerLive;
double timerArchive;
double timerGif;
GifMaker gif;
Capture cam;

void setup() {
  size(640, 480);

  // initialisation de la caméra
  String[] cameras = Capture.list();
  if (cameras == null) {
    println("Impossible de récupérer la liste des caméras disponibles, nous allons essayer avec celle par défaut...");
    cam = new Capture(this, 640, 480);
  } 
  if (cameras.length == 0) {
    println("Il n'y a pas de caméra disponible pour la capture.");
    exit();
  } else {
    println("Liste des caméras disponibles:");
    for (int i = 0; i < cameras.length; i++) {
      print(i + ". ");
      println(cameras[i]);
    }
    cam = new Capture(this, cameras[1]);
    cam.start();

    // initialisation du .gif pour les archives
    gif = new GifMaker(this, "8.gif");
    gif.setRepeat(0);
  }
}

void draw() {
  background(100);

  // configuration de la caméra
  if (cam.available() == true) {
    cam.read();
  }
  // inverse l'image sur l'axe horizontal
  scale(-1.0, 1.0);
  image(cam, -cam.width, 0);
  scale(-1.0, 1.0);

  // configuration des données temporelles
  int second = second();  // valeurs comprises entre 0 et 59
  int minute = minute();  // valeurs comprises entre 0 et 59
  int hour = hour();      // valeurs comprises entre 0 et 23
  int year = year();      // 2014, 2015, 2016, etc.
  int month = month();    // valeurs comprises entre 1 et 12
  int day = day();        // valeurs comprises entre 1 et 31
  String time = hour+":"+minute+":"+second;
  String date = year+"/"+month+"/"+day;
  String filigraneImage = date + " - " + time;
  // la ligne suivante ne sert que si l'on choisi d'enregistrer
  // toutes les images, ou bien une partie, en .jpg et non en .gif animé
  String filigraneSortie = year + "_" + month + "_" + day + "-" + hour + "_" + minute + "_" + second;
  Date formatDate = new Date();
  SimpleDateFormat SDFJour = new SimpleDateFormat("EEEE");
  SimpleDateFormat SDFNombre = new SimpleDateFormat("u");


  // affiche un cadre noir sous le filigrane, pour plus de lisibilité
  fill(0);
  rect(480, 450, 640, 480);
  // affiche le filigrane en blanc, centré, taille 12 avec la date et l'heure
  fill(255);
  textSize(12);
  textAlign(CENTER);
  text(filigraneImage, 560, 469);


  // enregistrement des images
  // on n'enregistre pas le week-end (NB: jour 1 = lundi)
  if (int(SDFNombre.format(formatDate)) < 6) {
    // on n'enregistre qu'entre 8h et 18h
    if (hour >= 8 && hour < 18) { 
      // enregistrement toute les 5 secondes pour la diffusion en "direct"
      if (millis() - timerLive >= 5*1000)
      {
        saveFrame("/live/live.jpg");
        timerLive = millis();
      }

      // enregistrement toutes les minutes pour les archives
      if (millis() - timerArchive >= 60*1000)
      {
        // cette ligne ne sert que si l'on enregistre une partie des images
        // en .jpg au lieu de .gif animé
        //saveFrame("/screenshots/"+ SDFJour.format(formatDate) + "/" + hour + "/" + minute + ".jpg");
        gif.addFrame();
        timerArchive = millis();
      }

      // export du .gif toutes les heures
      if (millis() - timerGif >= 60*60*1000)
      { 
        gif.finish();
        gif = new GifMaker(this, "/archives/" + SDFJour.format(formatDate) + "/" + hour + ".gif");
        gif.setRepeat(0);
        timerGif = millis();
      }
    }
  }
}

