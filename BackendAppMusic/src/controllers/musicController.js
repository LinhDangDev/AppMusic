
import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['playButton', 'pauseButton', 'stopButton', 'volumeSlider'];

  connect() {
    this.audio = new Audio(this.data.get('src'));
    this.audio.addEventListener('ended', this.stop.bind(this));
  }

  play() {
    this.audio.play();
    this.playButtonTarget.classList.add('hidden');
    this.pauseButtonTarget.classList.remove('hidden');
  }

  pause() {
    this.audio.pause();
    this.playButtonTarget.classList.remove('hidden');
    this.pauseButtonTarget.classList.add('hidden');
  }

  stop() {
    this.audio.pause();
    this.audio.currentTime = 0;
    this.playButtonTarget.classList.remove('hidden');
    this.pauseButtonTarget.classList.add('hidden');
  }

  adjustVolume() {
    this.audio.volume = this.volumeSliderTarget.value / 100;
  }
}
