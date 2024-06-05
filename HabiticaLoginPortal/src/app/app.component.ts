import {AfterViewInit, Component} from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { publish } from '@ionic/portals';
import {IonContent, IonHeader, IonSpinner, IonTitle, IonToolbar} from "@ionic/angular/standalone";

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, IonContent, IonHeader, IonToolbar, IonTitle, IonSpinner],
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss'
})
export class AppComponent implements AfterViewInit{

  ngAfterViewInit() {
    setTimeout(() => {
      publish({ topic: "loading", data: "end" });
    }, 3000);
  }
}
