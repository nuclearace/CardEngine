import React, { Component } from 'react';
import '../css/App.css';
import { BuildersGame } from './builders';

class App extends Component {
    render() {
        return (
            <div className='App'>
                <h1> Hello, World! </h1>
                <BuildersGame />
            </div>
        );
    }
}

export default App;
