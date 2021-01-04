import logo from './logo.svg';
import './App.css';
import Recipes from './components/Recipes'

function App() {
  return (
    <div className="App">
      <header className="cbheader"></header>
      <div className="cbcontainer">
        <Recipes></Recipes>
      </div>
      <footer className="cbfooter"></footer>
    </div>
  );
}

export default App;
