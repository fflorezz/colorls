# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ColorLS::Git do
  before(:all) do # rubocop:todo RSpec/BeforeAfterAll
    `echo` # initialize $CHILD_STATUS
    expect($CHILD_STATUS).to be_success # rubocop:todo RSpec/ExpectInHook
  end

  def git_status(*entries)
    StringIO.new entries.map { |line| "#{line}\u0000" }.join
  end

  context 'with file in repository root' do
    it 'returns `M`' do
      allow(subject).to receive(:git_prefix).with('/repo/').and_return(['', true])
      allow(subject).to receive(:git_subdir_status).and_yield(git_status(' M foo.txt'))

      expect(subject.status('/repo/')).to include('foo.txt' => Set['M'])
    end

    it 'returns `??`' do
      allow(subject).to receive(:git_prefix).with('/repo/').and_return(['', true])
      allow(subject).to receive(:git_subdir_status).and_yield(git_status('?? foo.txt'))

      expect(subject.status('/repo/')).to include('foo.txt' => Set['??'])
    end
  end

  context 'with file in subdir' do
    it 'returns `M` for subdir' do
      allow(subject).to receive(:git_prefix).with('/repo/').and_return(['', true])
      allow(subject).to receive(:git_subdir_status).and_yield(git_status(' M subdir/foo.txt'))

      expect(subject.status('/repo/')).to include('subdir' => Set['M'])
    end

    it 'returns `M` and `D` for subdir' do
      allow(subject).to receive(:git_prefix).with('/repo/').and_return(['', true])
      allow(subject).to receive(:git_subdir_status).and_yield(git_status(' M subdir/foo.txt', 'D  subdir/other.c'))

      expect(subject.status('/repo/')).to include('subdir' => Set['M', 'D'])
    end
  end
end
