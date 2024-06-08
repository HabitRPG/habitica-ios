import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import {
  IonButton,
  IonCard,
  IonCardContent,
  IonCardHeader,
  IonCardTitle,
  IonContent, IonItem,
  IonList,
  IonTitle
} from "@ionic/angular/standalone";
import {publish} from "@ionic/portals";

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, IonContent, IonCardHeader, IonTitle, IonCard, IonCardTitle, IonCardContent, IonList, IonItem, IonButton],
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss'
})
export class AppComponent {
  title = 'HabiticaAboutOFPortal';

  goBack() {
    publish({ topic: "navigate", data: "back" });
  }
}
