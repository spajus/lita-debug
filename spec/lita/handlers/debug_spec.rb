require "spec_helper"

describe Lita::Handlers::Debug, lita_handler: true do
  let(:robot) { Lita::Robot.new(registry) }
  subject { described_class.new(robot) }
  let(:room) { Lita::Room.new('foo_room') }
  let(:admin) { Lita::User.create(1, name: 'Admin User') }
  let(:eval_enabled) { false }

  before do
    registry.config.robot.admins = ['1']
    robot.auth.add_user_to_group!(admin, :debuggers)
    robot.auth.add_user_to_group!(admin, :evaluators)
    registry.config.handlers.debug.enable_eval = eval_enabled
    robot.trigger(:connected)
  end

  context 'unconfigured' do
    it 'routes debug for admins' do
      expect(subject).to route('lita debug')
        .with_authorization_for(:admins).to(:debug)
    end

    context 'with eval enabled' do
      let(:eval_enabled) { true }
      it 'routes eval for admins' do
        expect(subject).to route('lita eval 1+2')
          .with_authorization_for(:admins).to(:do_eval)
      end
    end
  end

  context 'configured' do
    let(:eval_enabled) { true }

    before do
      registry.config.handlers.debug.restrict_debug_to = :debuggers
      registry.config.handlers.debug.restrict_eval_to = :evaluators
    end

    it 'routes debug for debuggers' do
      expect(subject).to route('lita debug')
        .with_authorization_for(:debuggers).to(:debug)
    end

    it 'routes eval for evaluators' do
      expect(subject).to route('lita eval 1+2')
        .with_authorization_for(:evaluators).to(:do_eval)
    end
  end

  it 'debugs objects' do
    send_message('lita debug', from: room, as: admin)
    expect(replies.last).to include(room.name)
  end

  context 'with eval enabled' do
    before { registry.config.handlers.debug.enable_eval = true }
    it 'evals arbitrary ruby' do
      send_message('lita eval 1+2', from: room, as: admin)
      expect(replies.last).to eq('3')
    end

    it 'evals handler context' do
      send_message('lita eval response.room.name', from: room, as: admin)
      expect(replies.last).to eq('"foo_room"')
    end
  end
end
