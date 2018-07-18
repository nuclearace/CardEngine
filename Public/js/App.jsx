import React, { Component } from 'react';
import { Link, Switch, Route } from 'react-router-dom';
import '../css/App.css';
import { Builders } from './builders/Builders';

class App extends Component {
    render() {
        return (
            <div className='App'>
                <Route exact path='/index.html' component={GameSelector} />
                <Route path='/builders' render={() => <Builders />} />
            </div>
        );
    }
}

class GameSelector extends Component {
    render() {
        return (
            <div>
                <h1> Games </h1>
                <Switch>
                    <Link to='/builders' >The Builders</Link>
                </Switch>
            </div>
        );
    }
}

export default App;
