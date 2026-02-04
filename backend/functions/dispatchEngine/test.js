const { expect } = require('chai');
const sinon = require('sinon');
const dispatchEngine = require('../main'); // Adjust path

describe('Dispatch Engine', () => {
    it('should assign driver successfully', async () => {
        // Mock req, res, log, error, sdk
        const req = { payload: JSON.stringify({ order_id: 'order1' }) };
        const res = { json: sinon.spy() };
        const log = sinon.spy();
        const error = sinon.spy();
        const sdk = {
            Databases: sinon.stub().returns({
                getDocument: sinon.stub().resolves({ data: { pickup_lat: 32.8, pickup_lng: 13.2 } }),
                listDocuments: sinon.stub().resolves({ documents: [{ entity_id: 'driver1', lat: 32.9, lng: 13.3, rating: 5 }] }),
                updateDocument: sinon.stub().resolves()
            }),
            Query: { equal: sinon.stub(), orderDesc: sinon.stub() }
        };

        await dispatchEngine.default({ req, res, log, error, sdk });

        expect(res.json.calledWith({ success: true, status: 'assigned' })).to.be.true;
    });
});