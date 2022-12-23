import React, { Component } from 'react';
import Item from './Item'
import 'semantic-ui-css/semantic.min.css';
import { Card, Header, Menu, Input, Button, Checkbox } from 'semantic-ui-react'


// ----------------------------------------------------------------------------------------------------
// Show all the items
// ----------------------------------------------------------------------------------------------------
class AllItems extends Component
{
    handleChange = (e, { name, value }) => { this.setState({ [name]: value }); }

    constructor(props) {
        super (props);
        this.state = { search: '', loggedin: props.sessionid !== '' };
    }

    detailsname = (details) => {
        return (details.hasOwnProperty("name") ? details.name.toLowerCase() : '');
    }

    ItemCards = (data) => {
        return (
            data.data.itemAll.map(({ name, url, image, bookable, access, details }) => {
                if (bookable && (name.includes(this.state.search.toLowerCase()) || this.detailsname(details).includes(this.state.search.toLowerCase()) || (this.state.search === ""))) {
                    return (<Item sessionid={this.props.sessionid} name={name} url={url} image={image} bookable={bookable} access={access} details={details} />)
                }
                else { return (<></>); }
            })
        )
    }

    render ()
    {
        return (
            <>
                <Header centered as="h3" color='blue' block>
                    All items
                </Header>
                <Menu borderless color='blue' fluid widths={5} stackable>
                    <Menu.Item>Refine Search: </Menu.Item>
                    <Menu.Item>
                        <Input name='search' icon='search' placeholder='Search for item...' onChange={this.handleChange} />
                    </Menu.Item>
                    <Menu.Item>
                        <Checkbox label='Currently Available' />
                    </Menu.Item>
                    <Menu.Item>
                        {this.state.loggedin?<Checkbox label='Inducted'></Checkbox>:<Checkbox label='Inducted' disabled></Checkbox>}
                    </Menu.Item>
                    <Menu.Item>
                        <Button onClick={this.state.loggedin?this.props.dologout:this.props.dologin}>Log {this.state.loggedin?"out":"in"}</Button>
                    </Menu.Item>
                </Menu>
                <Card.Group centered>
                    <this.ItemCards data={this.props.data} />
                </Card.Group>
            </>
        )
    }
}

export default AllItems;
// ----------------------------------------------------------------------------------------------------
