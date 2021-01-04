import logo from './logo.svg';
import './App.css';

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          Edit <code>src/App.js</code> and save to reload.
        </p>
        <a
          className="App-link"
          href="https://reactjs.org"
          target="_blank"
          rel="noopener noreferrer"
        >
          Learn React
        </a>
        {/* TODO: Convert below to a refresh-state style API call to our API */}
        <a className="toxic-test" href="http://localhost:8001/" target="_blank" rel="open toxic api">Click here to trigger fast API</a>
      </header>
    </div>
  );
}

export default App;
