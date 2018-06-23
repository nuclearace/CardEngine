import React, { Component } from 'react';
import { Route, Link } from 'react-router-dom';
import '../css/App.css';
import { Builders } from './builders/Builders';

class App extends Component {
    render() {
        return (
            <div className='App'>
                <h1> Games </h1>
                <Link to='/builders' >The Builders</Link>
                <Route path='/builders' component={Builders} />
            </div>
        );
    }
}

export default App;
