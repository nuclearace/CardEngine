import React, { Component } from 'react';
import '../css/App.css';
import { BuildersGame } from './builders/components';

class App extends Component {
    render() {
        return (
            <div className='App'>
                <h1> The Builders </h1>
                <BuildersGame />
            </div>
        );
    }
}

export default App;
